import 'metric_value.dart';

/// Enumeration of standardized financial metrics.
enum FinancialMetric {
  // Income Statement (6)
  revenue('Revenue', 'Total revenue from operations'),
  grossProfit('Gross Profit', 'Revenue minus cost of goods sold'),
  operatingIncome('Operating Income', 'Income from core operations'),
  netIncome('Net Income', 'Bottom line profit/loss'),
  earningsPerShareBasic('EPS (Basic)', 'Earnings per share - basic'),
  earningsPerShareDiluted('EPS (Diluted)', 'Earnings per share - diluted'),
  researchAndDevelopment('R&D Expense', 'Research and development costs'),
  costOfRevenue('Cost of Revenue', 'Direct costs of goods/services'),

  // Balance Sheet (7)
  totalAssets('Total Assets', 'Sum of all assets'),
  totalLiabilities('Total Liabilities', 'Sum of all liabilities'),
  stockholdersEquity(
    'Stockholders Equity',
    'Net assets attributable to shareholders',
  ),
  cashAndEquivalents('Cash & Equivalents', 'Liquid assets'),
  currentAssets('Current Assets', 'Assets convertible to cash within 1 year'),
  currentLiabilities('Current Liabilities', 'Obligations due within 1 year'),
  nonCurrentLiabilities(
    'Non-Current Liabilities',
    'Long-term obligations due after 1 year',
  ),
  longTermDebt('Long-term Debt', 'Debt obligations due after 1 year'),

  // Cash Flow (6)
  operatingCashFlow('Operating Cash Flow', 'Cash from core operations'),
  investingCashFlow('Investing Cash Flow', 'Cash from investments'),
  financingCashFlow('Financing Cash Flow', 'Cash from financing activities'),
  capitalExpenditures(
    'Capital Expenditures',
    'Payments for property, plant, and equipment',
  ),
  depreciationAmortization(
    'Depreciation & Amortization',
    'Non-cash charges for asset depreciation and amortization',
  ),
  dividendsPaid('Dividends Paid', 'Total cash dividends paid to shareholders'),

  // Other (2)
  sharesOutstanding(
    'Shares Outstanding',
    'Total shares issued and outstanding',
  ),
  dividendsPerShare('Dividends Per Share', 'Dividend paid per share');

  const FinancialMetric(this.displayName, this.description);

  final String displayName;
  final String description;
}

/// Historical data for a single metric across multiple periods.
class MetricHistory {
  const MetricHistory({required this.metric, required this.values});
  final FinancialMetric metric;
  final List<FinancialMetricValue> values;

  /// Get values for annual periods only.
  List<FinancialMetricValue> get annualValues =>
      values.where((v) => v.fiscalPeriod.isAnnual).toList();

  /// Get values for quarterly periods only.
  List<FinancialMetricValue> get quarterlyValues =>
      values.where((v) => v.fiscalPeriod.isQuarterly).toList();

  /// Get values for a specific year.
  List<FinancialMetricValue> forYear(int year) =>
      values.where((v) => v.fiscalPeriod.year == year).toList();

  /// Get the most recent value.
  FinancialMetricValue? get latest => values.isEmpty
      ? null
      : values.reduce((a, b) => a.endDate.isAfter(b.endDate) ? a : b);

  /// Get values sorted by date (newest first).
  List<FinancialMetricValue> get sortedByDate =>
      List.from(values)..sort((a, b) => b.endDate.compareTo(a.endDate));

  Map<String, dynamic> toJson() => {
        'metric': metric.name,
        'displayName': metric.displayName,
        'values': values.map((v) => v.toJson()).toList(),
      };
}
