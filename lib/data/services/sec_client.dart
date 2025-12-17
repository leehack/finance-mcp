import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import '../models/company_financials.dart';
import '../models/metric_history.dart';
import 'financial_data_service.dart';
import 'financial_parser.dart';

/// SEC EDGAR API client implementing [FinancialDataService].
///
/// Fetches company data from SEC's XBRL API and parses it into
/// structured financial models.
class SecClient implements FinancialDataService {
  SecClient({http.Client? client, FinancialParser? parser})
      : _client = client ?? http.Client(),
        _parser = parser ?? FinancialParser();

  final http.Client _client;
  final FinancialParser _parser;
  final Logger _logger = Logger('SecClient');

  // SEC requires a User-Agent in the format: "Sample Company Name AdminContact@<domain>.com"
  static const String _userAgent = 'FinanceMCPBot jhin.lee@example.com';
  static const String _baseUrl = 'https://data.sec.gov/api/xbrl';
  static const String _tickersUrl =
      'https://www.sec.gov/files/company_tickers.json';

  Map<String, int>? _tickerCache;

  @override
  Future<int?> getCik(String ticker) async {
    if (_tickerCache == null) {
      await _refreshTickerCache();
    }
    return _tickerCache?[ticker.toUpperCase()];
  }

  Future<void> _refreshTickerCache() async {
    _logger.info('Fetching ticker mapping from SEC...');
    try {
      final response = await _get(_tickersUrl);
      final data = json.decode(response.body) as Map<String, dynamic>;

      _tickerCache = {};
      data.forEach((key, value) {
        // Value is like {"cik_str": 320193, "ticker": "AAPL", "title": "Apple Inc."}
        final ticker = value['ticker'] as String;
        final cik = value['cik_str'] as int;
        _tickerCache![ticker] = cik;
      });
      _logger.info('Cached ${_tickerCache?.length} tickers.');
    } catch (e) {
      _logger.severe('Failed to refresh ticker cache: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getCompanyFacts(String ticker) async {
    final cik = await getCik(ticker);
    if (cik == null) {
      throw Exception('Ticker $ticker not found.');
    }

    // CIK must be 10 digits, zero-padded
    final cikStr = cik.toString().padLeft(10, '0');
    final url = '$_baseUrl/companyfacts/CIK$cikStr.json';

    _logger.info('Fetching facts for $ticker (CIK: $cikStr)...');
    final response = await _get(url);
    return json.decode(response.body) as Map<String, dynamic>;
  }

  @override
  Future<CompanyFinancials> getHistoricalFinancials(
    String ticker, {
    int years = 10,
    bool includeQuarterly = true,
    Set<FinancialMetric>? metrics,
  }) async {
    final cik = await getCik(ticker);
    if (cik == null) {
      throw Exception('Ticker $ticker not found.');
    }

    final facts = await getCompanyFacts(ticker);

    return _parser.parseCompanyFacts(
      ticker: ticker,
      cik: cik,
      facts: facts,
      options: FetchOptions(
        years: years,
        includeQuarterly: includeQuarterly,
        metricsToFetch: metrics,
      ),
    );
  }

  Future<http.Response> _get(String url) async {
    final uri = Uri.parse(url);
    final response = await _client.get(
      uri,
      headers: {
        'User-Agent': _userAgent,
        'Accept-Encoding': 'gzip, deflate',
        'Host': uri.host,
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load $url: ${response.statusCode} ${response.reasonPhrase}',
      );
    }
    return response;
  }

  @override
  void close() {
    _client.close();
  }
}
