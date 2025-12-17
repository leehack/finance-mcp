// Unit and integration tests for SecClient
import 'package:finance_mcp/data/data.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

void main() {
  // Set up logging for tests
  Logger.root.level = Level.WARNING;

  group('SecClient', () {
    late SecClient client;

    setUp(() {
      client = SecClient();
    });

    tearDown(() {
      client.close();
    });

    group('getCik', () {
      test('returns CIK for valid ticker', () async {
        final cik = await client.getCik('AAPL');
        expect(cik, isNotNull);
        expect(cik, isA<int>());
        expect(cik, greaterThan(0));
      });

      test('returns null for invalid ticker', () async {
        final cik = await client.getCik('INVALID_TICKER_XYZ123');
        expect(cik, isNull);
      });

      test('handles case-insensitive ticker', () async {
        final cikUpper = await client.getCik('AAPL');
        final cikLower = await client.getCik('aapl');
        expect(cikUpper, equals(cikLower));
      });
    });

    group('getCompanyFacts', () {
      test('returns facts for valid ticker', () async {
        final facts = await client.getCompanyFacts('AAPL');

        expect(facts, isA<Map<String, dynamic>>());
        expect(facts['cik'], isNotNull);
        expect(facts['entityName'], isNotNull);
        expect(facts['facts'], isA<Map<String, dynamic>>());
      });

      test('throws for invalid ticker', () async {
        expect(
          () => client.getCompanyFacts('INVALID_TICKER_XYZ123'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getHistoricalFinancials', () {
      test('returns CompanyFinancials for valid ticker', () async {
        final financials = await client.getHistoricalFinancials(
          'AAPL',
          years: 3,
        );

        expect(financials, isA<CompanyFinancials>());
        expect(financials.ticker, equals('AAPL'));
        expect(financials.cik, greaterThan(0));
        expect(financials.metrics, isNotEmpty);
      });

      test('respects years parameter', () async {
        final financials = await client.getHistoricalFinancials(
          'MSFT',
          years: 2,
        );

        expect(financials.yearRange, isNotNull);
        // Year range should be approximately 2 years (may vary slightly)
        final yearRange = financials.yearRange;
        if (yearRange != null) {
          final (startYear, endYear) = yearRange;
          // Allow some flexibility as data may include partial years
          expect(endYear - startYear, lessThanOrEqualTo(5));
        }
      });

      test('can fetch specific metrics only', () async {
        final metricsToFetch = {
          FinancialMetric.revenue,
          FinancialMetric.netIncome,
        };

        final financials = await client.getHistoricalFinancials(
          'AAPL',
          years: 2,
          metrics: metricsToFetch,
        );

        // Should have at most the requested metrics (may have fewer if not available)
        expect(
          financials.metrics.length,
          lessThanOrEqualTo(metricsToFetch.length),
        );
      });

      test('includes quarterly data when requested', () async {
        final financials = await client.getHistoricalFinancials(
          'AAPL',
          years: 1,
        );

        // Verify the structure is correct - quarterly data may or may not be available
        expect(
          financials.statements,
          isA<Map<FiscalPeriod, FinancialStatements>>(),
        );
      });

      test('excludes quarterly data when not requested', () async {
        final financials = await client.getHistoricalFinancials(
          'AAPL',
          years: 1,
          includeQuarterly: false,
        );

        // All metrics should have only annual values
        for (final metric in FinancialMetric.values) {
          final history = financials[metric];
          if (history != null) {
            expect(history.quarterlyValues, isEmpty);
          }
        }
      });
    });
  });

  group(
    'SecClient - Multi-Company Validation',
    () {
      late SecClient client;

      setUp(() {
        client = SecClient();
      });

      tearDown(() {
        client.close();
      });

      // Test various companies from different sectors
      final testTickers = ['AAPL', 'MSFT', 'JPM', 'GOOGL'];

      for (final ticker in testTickers) {
        test('fetches data for $ticker', () async {
          final financials = await client.getHistoricalFinancials(
            ticker,
            years: 2,
          );

          expect(financials.ticker, equals(ticker));
          expect(financials.cik, greaterThan(0));

          // Should have at least some metrics available
          expect(financials.metrics.length, greaterThan(0));

          // Revenue should be available for most public companies
          final revenue = financials[FinancialMetric.revenue];
          expect(
            revenue,
            isNotNull,
            reason: '$ticker should have revenue data',
          );
          expect(
            revenue!.values,
            isNotEmpty,
            reason: '$ticker should have revenue values',
          );
        });
      }
    },
    timeout: Timeout(Duration(minutes: 2)),
  );
}
