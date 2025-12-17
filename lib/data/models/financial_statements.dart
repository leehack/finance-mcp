import 'balance_sheet.dart';
import 'cash_flow_statement.dart';
import 'fiscal_period.dart';
import 'income_statement.dart';

/// Complete financial statements for a single fiscal period.
class FinancialStatements {
  const FinancialStatements({
    required this.fiscalPeriod,
    required this.incomeStatement,
    required this.balanceSheet,
    required this.cashFlowStatement,
    this.sharesOutstanding,
    this.dividendsPerShare,
  });

  final FiscalPeriod fiscalPeriod;
  final IncomeStatement incomeStatement;
  final BalanceSheet balanceSheet;
  final CashFlowStatement cashFlowStatement;
  final double? sharesOutstanding;
  final double? dividendsPerShare;

  // ============= Intrinsic Value Metrics =============

  /// Return on Equity (ROE) = Net Income / Stockholders Equity.
  /// Measures profitability relative to shareholder equity.
  double? get returnOnEquity {
    final netIncome = incomeStatement.netIncome;
    final equity = balanceSheet.stockholdersEquity;
    if (netIncome == null || equity == null || equity == 0) return null;
    return netIncome / equity;
  }

  /// Invested Capital = Total Assets - Current Liabilities - Cash.
  /// Represents the capital actively invested in operations.
  double? get investedCapital {
    final assets = balanceSheet.totalAssets;
    final currentLiab = balanceSheet.currentLiabilities;
    final cash = balanceSheet.cashAndEquivalents;
    if (assets == null) return null;
    return assets - (currentLiab ?? 0) - (cash ?? 0);
  }

  /// Return on Invested Capital (ROIC) = NOPAT / Invested Capital.
  /// NOPAT = Operating Income * (1 - tax rate).
  /// Uses default 21% US corporate tax rate if not specified.
  double? roic({double taxRate = 0.21}) {
    final operatingIncome = incomeStatement.operatingIncome;
    final capital = investedCapital;
    if (operatingIncome == null || capital == null || capital == 0) {
      return null;
    }
    final nopat = operatingIncome * (1 - taxRate);
    return nopat / capital;
  }

  /// Return on Capital (ROC) = (Net Income - Dividends) / (Equity + Non-Current Liabilities).
  /// This measures how efficiently the company uses its total capital base.
  double? get returnOnCapital {
    final netIncome = incomeStatement.netIncome;
    final equity = balanceSheet.stockholdersEquity;
    final nonCurrentLiab = balanceSheet.nonCurrentLiabilities;
    final dividends = cashFlowStatement.dividendsPaid;

    if (netIncome == null || equity == null || nonCurrentLiab == null) {
      return null;
    }

    final capitalBase = equity + nonCurrentLiab;
    if (capitalBase == 0) return null;

    // Dividends paid is typically negative in cash flow (outflow)
    // so we add it to net income (subtracting a negative = adding)
    final retainedEarnings = netIncome - (dividends?.abs() ?? 0);
    return retainedEarnings / capitalBase;
  }

  /// Return on Assets (ROA) = Net Income / Total Assets.
  /// Measures how efficiently assets generate profit.
  double? get returnOnAssets {
    final netIncome = incomeStatement.netIncome;
    final assets = balanceSheet.totalAssets;
    if (netIncome == null || assets == null || assets == 0) return null;
    return netIncome / assets;
  }

  /// Earnings Yield = EPS / Price (inverse of P/E).
  /// Returns null since we don't have price data yet.
  /// Use with external price: `earningsYield(price)`.
  double? earningsYield(double? stockPrice) {
    final eps = incomeStatement.earningsPerShareDiluted ??
        incomeStatement.earningsPerShareBasic;
    if (eps == null || stockPrice == null || stockPrice == 0) return null;
    return eps / stockPrice;
  }

  /// Price to Earnings ratio.
  /// Returns null since we don't have price data internally.
  /// Use with external price: `priceToEarnings(price)`.
  double? priceToEarnings(double? stockPrice) {
    final eps = incomeStatement.earningsPerShareDiluted ??
        incomeStatement.earningsPerShareBasic;
    if (eps == null || stockPrice == null || eps == 0) return null;
    return stockPrice / eps;
  }

  /// Book Value Per Share = Stockholders Equity / Shares Outstanding.
  double? get bookValuePerShare {
    final equity = balanceSheet.stockholdersEquity;
    final shares = sharesOutstanding;
    if (equity == null || shares == null || shares == 0) return null;
    return equity / shares;
  }

  /// Price to Book ratio.
  /// Use with external price: `priceToBook(price)`.
  double? priceToBook(double? stockPrice) {
    final bvps = bookValuePerShare;
    if (bvps == null || stockPrice == null || bvps == 0) return null;
    return stockPrice / bvps;
  }

  Map<String, dynamic> toJson() => {
        'fiscalPeriod': fiscalPeriod.toString(),
        'incomeStatement': incomeStatement.toJson(),
        'balanceSheet': balanceSheet.toJson(),
        'cashFlowStatement': cashFlowStatement.toJson(),
        if (sharesOutstanding != null) 'sharesOutstanding': sharesOutstanding,
        if (dividendsPerShare != null) 'dividendsPerShare': dividendsPerShare,
        // Intrinsic value metrics
        if (returnOnEquity != null) 'returnOnEquity': returnOnEquity,
        if (returnOnAssets != null) 'returnOnAssets': returnOnAssets,
        if (returnOnCapital != null) 'returnOnCapital': returnOnCapital,
        if (investedCapital != null) 'investedCapital': investedCapital,
        if (roic() != null) 'roic': roic(),
        if (bookValuePerShare != null) 'bookValuePerShare': bookValuePerShare,
      };
}
