// Unit tests for financial data models
import 'package:finance_mcp/data/data.dart';
import 'package:test/test.dart';

void main() {
  group('FiscalPeriod', () {
    test('isAnnual returns true for FY period', () {
      final period = FiscalPeriod(year: 2023, period: 'FY');
      expect(period.isAnnual, isTrue);
      expect(period.isQuarterly, isFalse);
    });

    test('isQuarterly returns true for Q periods', () {
      for (final q in ['Q1', 'Q2', 'Q3', 'Q4']) {
        final period = FiscalPeriod(year: 2023, period: q);
        expect(period.isQuarterly, isTrue);
        expect(period.isAnnual, isFalse);
      }
    });

    test('equality works correctly', () {
      final p1 = FiscalPeriod(year: 2023, period: 'FY');
      final p2 = FiscalPeriod(year: 2023, period: 'FY');
      final p3 = FiscalPeriod(year: 2024, period: 'FY');
      expect(p1, equals(p2));
      expect(p1, isNot(equals(p3)));
      expect(p1.hashCode, equals(p2.hashCode));
    });
  });

  group('IncomeStatement', () {
    test('grossMargin calculates correctly', () {
      final income = IncomeStatement(
        revenue: 100000,
        grossProfit: 40000,
      );
      expect(income.grossMargin, closeTo(0.4, 0.001));
    });

    test('operatingMargin calculates correctly', () {
      final income = IncomeStatement(
        revenue: 100000,
        operatingIncome: 25000,
      );
      expect(income.operatingMargin, closeTo(0.25, 0.001));
    });

    test('netMargin calculates correctly', () {
      final income = IncomeStatement(
        revenue: 100000,
        netIncome: 15000,
      );
      expect(income.netMargin, closeTo(0.15, 0.001));
    });

    test('margins return null when revenue is zero', () {
      final income = IncomeStatement(
        revenue: 0,
        grossProfit: 40000,
        netIncome: 15000,
      );
      expect(income.grossMargin, isNull);
      expect(income.netMargin, isNull);
    });

    test('margins return null when numerator is null', () {
      final income = IncomeStatement(revenue: 100000);
      expect(income.grossMargin, isNull);
      expect(income.operatingMargin, isNull);
      expect(income.netMargin, isNull);
    });
  });

  group('BalanceSheet', () {
    test('currentRatio calculates correctly', () {
      final balance = BalanceSheet(
        currentAssets: 50000,
        currentLiabilities: 25000,
      );
      expect(balance.currentRatio, closeTo(2.0, 0.001));
    });

    test('debtToEquity calculates correctly', () {
      final balance = BalanceSheet(
        longTermDebt: 30000,
        stockholdersEquity: 100000,
      );
      expect(balance.debtToEquity, closeTo(0.3, 0.001));
    });

    test('currentRatio returns null when liabilities is zero', () {
      final balance = BalanceSheet(
        currentAssets: 50000,
        currentLiabilities: 0,
      );
      expect(balance.currentRatio, isNull);
    });
  });

  group('CashFlowStatement', () {
    test('freeCashFlow calculates correctly', () {
      final cashFlow = CashFlowStatement(
        operatingCashFlow: 50000,
        investingCashFlow: -20000,
      );
      expect(cashFlow.freeCashFlow, equals(30000));
    });

    test('netCashChange sums all cash flows', () {
      final cashFlow = CashFlowStatement(
        operatingCashFlow: 50000,
        investingCashFlow: -20000,
        financingCashFlow: -15000,
      );
      expect(cashFlow.netCashChange, equals(15000));
    });

    test('freeCashFlow returns null when operatingCashFlow is null', () {
      final cashFlow = CashFlowStatement(investingCashFlow: -20000);
      expect(cashFlow.freeCashFlow, isNull);
    });
  });

  group('FinancialStatements', () {
    late FinancialStatements statements;

    setUp(() {
      statements = FinancialStatements(
        fiscalPeriod: FiscalPeriod(year: 2023, period: 'FY'),
        incomeStatement: IncomeStatement(
          netIncome: 50000,
          operatingIncome: 60000,
        ),
        balanceSheet: BalanceSheet(
          totalAssets: 500000,
          stockholdersEquity: 200000,
          nonCurrentLiabilities: 150000,
          currentLiabilities: 50000,
          cashAndEquivalents: 30000,
        ),
        cashFlowStatement: CashFlowStatement(
          operatingCashFlow: 70000,
          investingCashFlow: -25000,
          dividendsPaid: -10000,
        ),
        sharesOutstanding: 10000,
      );
    });

    test('returnOnEquity calculates correctly', () {
      // ROE = 50000 / 200000 = 0.25
      expect(statements.returnOnEquity, closeTo(0.25, 0.001));
    });

    test('returnOnAssets calculates correctly', () {
      // ROA = 50000 / 500000 = 0.10
      expect(statements.returnOnAssets, closeTo(0.10, 0.001));
    });

    test('returnOnCapital calculates correctly using user formula', () {
      // ROC = (NetIncome - Dividends) / (Equity + NonCurrentLiabilities)
      // ROC = (50000 - 10000) / (200000 + 150000) = 40000 / 350000 ≈ 0.1143
      expect(statements.returnOnCapital, closeTo(0.1143, 0.001));
    });

    test('investedCapital calculates correctly', () {
      // Invested Capital = Assets - CurrentLiab - Cash
      // = 500000 - 50000 - 30000 = 420000
      expect(statements.investedCapital, equals(420000));
    });

    test('roic calculates correctly with default tax rate', () {
      // ROIC = NOPAT / InvestedCapital
      // NOPAT = 60000 * (1 - 0.21) = 47400
      // ROIC = 47400 / 420000 ≈ 0.1129
      expect(statements.roic(), closeTo(0.1129, 0.001));
    });

    test('roic uses custom tax rate', () {
      // NOPAT = 60000 * (1 - 0.25) = 45000
      // ROIC = 45000 / 420000 ≈ 0.1071
      expect(statements.roic(taxRate: 0.25), closeTo(0.1071, 0.001));
    });

    test('bookValuePerShare calculates correctly', () {
      // BVPS = 200000 / 10000 = 20
      expect(statements.bookValuePerShare, equals(20.0));
    });

    test('priceToEarnings calculates correctly with external price', () {
      final stmtWithEps = FinancialStatements(
        fiscalPeriod: FiscalPeriod(year: 2023, period: 'FY'),
        incomeStatement: IncomeStatement(earningsPerShareDiluted: 5),
        balanceSheet: BalanceSheet(),
        cashFlowStatement: CashFlowStatement(),
      );
      // P/E = 100 / 5 = 20
      expect(stmtWithEps.priceToEarnings(100), equals(20.0));
    });

    test('priceToBook calculates correctly with external price', () {
      // P/B = 100 / 20 = 5
      expect(statements.priceToBook(100), equals(5.0));
    });

    test('earningsYield calculates correctly with external price', () {
      final stmtWithEps = FinancialStatements(
        fiscalPeriod: FiscalPeriod(year: 2023, period: 'FY'),
        incomeStatement: IncomeStatement(earningsPerShareDiluted: 5),
        balanceSheet: BalanceSheet(),
        cashFlowStatement: CashFlowStatement(),
      );
      // Yield = 5 / 100 = 0.05
      expect(stmtWithEps.earningsYield(100), equals(0.05));
    });
  });

  group('CompanyFinancials', () {
    late CompanyFinancials financials;

    setUp(() {
      final statements = <FiscalPeriod, FinancialStatements>{};

      // Create 5 years of annual data with varying ROC
      for (var year = 2019; year <= 2023; year++) {
        final period = FiscalPeriod(year: year, period: 'FY');
        statements[period] = FinancialStatements(
          fiscalPeriod: period,
          incomeStatement:
              IncomeStatement(netIncome: 50000.0 + (year - 2019) * 5000),
          balanceSheet: BalanceSheet(
            stockholdersEquity: 200000,
            nonCurrentLiabilities: 100000,
          ),
          cashFlowStatement: CashFlowStatement(
            dividendsPaid: -10000,
          ),
        );
      }

      financials = CompanyFinancials(
        ticker: 'TEST',
        cik: 123456,
        metrics: {},
        statements: statements,
        fetchedAt: DateTime.now(),
      );
    });

    test('annualStatements returns sorted list', () {
      expect(financials.annualStatements.length, equals(5));
      expect(financials.annualStatements.first.fiscalPeriod.year, equals(2023));
      expect(financials.annualStatements.last.fiscalPeriod.year, equals(2019));
    });

    test('annualROCs returns ROC values', () {
      final rocs = financials.annualROCs;
      expect(rocs.length, equals(5));
      // Oldest first (2019 to 2023)
      // 2019: (50000 - 10000) / (200000 + 100000) = 40000/300000 ≈ 0.1333
      expect(rocs.first, closeTo(0.1333, 0.001));
    });

    test('medianROC returns median value', () {
      // 5 values, median is the 3rd value when sorted
      final medianRoc = financials.medianROC;
      expect(medianRoc, isNotNull);
      // ROCs: 0.1333, 0.15, 0.1667, 0.1833, 0.2
      // Median (sorted) = 0.1667
      expect(medianRoc, closeTo(0.1667, 0.01));
    });

    test('averageROC returns average value', () {
      final avgRoc = financials.averageROC;
      expect(avgRoc, isNotNull);
      // Average of 5 ROC values
      expect(avgRoc, closeTo(0.1667, 0.01));
    });

    test('medianROC returns null when no data', () {
      final emptyFinancials = CompanyFinancials(
        ticker: 'EMPTY',
        cik: 0,
        metrics: {},
        statements: {},
        fetchedAt: DateTime.now(),
      );
      expect(emptyFinancials.medianROC, isNull);
      expect(emptyFinancials.averageROC, isNull);
    });

    test('getStatement returns correct statement', () {
      final stmt =
          financials.getStatement(FiscalPeriod(year: 2023, period: 'FY'));
      expect(stmt, isNotNull);
      expect(stmt!.fiscalPeriod.year, equals(2023));
    });

    test('availablePeriods returns sorted periods', () {
      final periods = financials.availablePeriods;
      expect(periods.length, equals(5));
      expect(periods.first.year, equals(2023));
    });
  });

  group('DcfValuation', () {
    test('enterpriseValue calculates correctly', () {
      final dcf = DcfValuation(
        freeCashFlow: 100000,
        sharesOutstanding: 10000,
      );
      // Enterprise value should be positive and significant
      expect(dcf.enterpriseValue, greaterThan(100000));
    });

    test('intrinsicValuePerShare calculates correctly', () {
      final dcf = DcfValuation(
        freeCashFlow: 100000,
        sharesOutstanding: 10000,
      );
      expect(dcf.intrinsicValuePerShare, equals(dcf.enterpriseValue / 10000));
    });

    test('marginOfSafety calculates correctly', () {
      final dcf = DcfValuation(
        freeCashFlow: 100000,
        sharesOutstanding: 10000,
      );
      final intrinsic = dcf.intrinsicValuePerShare;
      final price = intrinsic * 0.8; // 20% below intrinsic
      expect(dcf.marginOfSafety(price), closeTo(0.2, 0.001));
    });

    test('fromStatements creates DCF from statement', () {
      final statements = FinancialStatements(
        fiscalPeriod: FiscalPeriod(year: 2023, period: 'FY'),
        incomeStatement: IncomeStatement(),
        balanceSheet: BalanceSheet(),
        cashFlowStatement: CashFlowStatement(
          operatingCashFlow: 100000,
          investingCashFlow: -30000,
        ),
        sharesOutstanding: 10000,
      );

      final dcf = DcfValuation.fromStatements(statements, growthRate: 0.08);
      expect(dcf, isNotNull);
      expect(dcf!.freeCashFlow, equals(70000));
      expect(dcf.sharesOutstanding, equals(10000));
      expect(dcf.growthRate, equals(0.08));
    });

    test('fromStatements returns null when FCF is negative', () {
      final statements = FinancialStatements(
        fiscalPeriod: FiscalPeriod(year: 2023, period: 'FY'),
        incomeStatement: IncomeStatement(),
        balanceSheet: BalanceSheet(),
        cashFlowStatement: CashFlowStatement(
          operatingCashFlow: 30000,
          investingCashFlow: -50000, // FCF = -20000
        ),
        sharesOutstanding: 10000,
      );

      final dcf = DcfValuation.fromStatements(statements);
      expect(dcf, isNull);
    });

    test('DCF with medianROC as growth rate', () {
      // Simulate using median ROC as growth rate
      final medianROC = 0.15;
      final dcf = DcfValuation(
        freeCashFlow: 100000,
        sharesOutstanding: 10000,
        growthRate: medianROC,
      );
      expect(dcf.intrinsicValuePerShare, greaterThan(0));
    });
  });
}
