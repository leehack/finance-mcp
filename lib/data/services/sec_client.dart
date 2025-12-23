import 'dart:convert';

import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import '../models/company_financials.dart';
import '../models/metric_history.dart';
import '../models/sec_filing.dart';
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
  static const String _submissionsUrl = 'https://data.sec.gov/submissions';
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

  @override
  Future<List<SecFiling>> getRecentFilings(
    String ticker, {
    List<String>? forms,
    int limit = 10,
  }) async {
    final cik = await getCik(ticker);
    if (cik == null) {
      throw Exception('Ticker $ticker not found.');
    }

    final cikStr = cik.toString().padLeft(10, '0');
    final url = '$_submissionsUrl/CIK$cikStr.json';

    _logger.info('Fetching filings for $ticker (CIK: $cikStr)...');
    final response = await _get(url);
    final data = json.decode(response.body) as Map<String, dynamic>;

    // Parse recent filings from the response
    final recentFilings = data['filings']?['recent'] as Map<String, dynamic>?;
    if (recentFilings == null) {
      return [];
    }

    final accessionNumbers = recentFilings['accessionNumber'] as List<dynamic>;
    final formTypes = recentFilings['form'] as List<dynamic>;
    final filingDates = recentFilings['filingDate'] as List<dynamic>;
    final primaryDocuments = recentFilings['primaryDocument'] as List<dynamic>;
    final descriptions =
        recentFilings['primaryDocDescription'] as List<dynamic>?;

    final filings = <SecFiling>[];
    for (var i = 0;
        i < accessionNumbers.length && filings.length < limit;
        i++) {
      final form = formTypes[i] as String;

      // Filter by form type if specified
      if (forms != null && !forms.contains(form)) {
        continue;
      }

      filings.add(
        SecFiling(
          accessionNumber: accessionNumbers[i] as String,
          form: form,
          filingDate: DateTime.parse(filingDates[i] as String),
          primaryDocument: primaryDocuments[i] as String,
          description: descriptions?[i] as String? ?? '',
          cik: cik,
        ),
      );
    }

    _logger.info('Found ${filings.length} filings for $ticker.');
    return filings;
  }

  @override
  Future<String> getFilingContent(SecFiling filing) async {
    _logger.info(
      'Fetching content for ${filing.form} (${filing.accessionNumber})...',
    );
    final response = await _get(filing.url);

    // Parse HTML and extract text content
    return _extractTextFromHtml(response.body);
  }

  /// Extracts plain text from HTML content.
  ///
  /// Removes all HTML tags, scripts, styles, XBRL metadata, and cleans up
  /// whitespace for easier sentiment analysis.
  String _extractTextFromHtml(String html) {
    final document = html_parser.parse(html);

    // Remove script, style, and metadata elements
    document.querySelectorAll('script, style, noscript, meta, link').forEach(
          (e) => e.remove(),
        );

    // Remove XBRL/iXBRL hidden elements (these contain metadata, not readable text)
    // ix:hidden contains XBRL context data that shows as garbage text
    document
        .querySelectorAll('[style*="display:none"], [style*="display: none"]')
        .forEach(
          (e) => e.remove(),
        );

    // Remove elements with common XBRL namespaces that contain metadata
    document
        .querySelectorAll(r'ix\:hidden, ix\:header, ix\:references')
        .forEach(
          (e) => e.remove(),
        );

    // Get text content
    var text = document.body?.text ?? '';

    // Remove common XBRL metadata patterns that leak through
    // Pattern: sequences of "true/false" and ticker identifiers
    text = text.replaceAll(RegExp('(true|false){3,}'), '');
    text = text.replaceAll(RegExp('NASDAQ{2,}'), '');
    text = text.replaceAll(RegExp(r'\d{10}\d{10}[\d-]+'), '');

    // Clean up whitespace: collapse multiple spaces/newlines
    text = text
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .replaceAll(RegExp(r'\n[ \t]*\n'), '\n\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();

    return text;
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
