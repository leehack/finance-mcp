/// Concept mapping from standardized metrics to SEC XBRL tags.
///
/// Based on discovery across 35 companies including large caps, mid caps,
/// small caps from tech, finance, healthcare, retail, and energy sectors.
library;

import '../models/metric_history.dart';

/// Maps standardized metrics to possible SEC XBRL concept tags.
/// Tags are ordered by priority - more common/reliable tags first.
const Map<FinancialMetric, List<String>> conceptMappings = {
  // Income Statement
  FinancialMetric.revenue: [
    'RevenueFromContractWithCustomerExcludingAssessedTax',
    'Revenues',
    'SalesRevenueNet',
    'RevenueFromContractWithCustomerIncludingAssessedTax',
    'SalesRevenueGoodsNet',
    'SalesRevenueServicesNet',
    'RevenuesNetOfInterestExpense', // Banks
    'InterestAndDividendIncomeOperating', // Banks
    'TotalRevenuesAndOtherIncome',
  ],

  FinancialMetric.grossProfit: [
    'GrossProfit',
  ],

  FinancialMetric.operatingIncome: [
    'OperatingIncomeLoss',
    'IncomeLossFromContinuingOperationsBeforeIncomeTaxesExtraordinaryItemsNoncontrollingInterest',
  ],

  FinancialMetric.netIncome: [
    'NetIncomeLoss',
    'NetIncomeLossAvailableToCommonStockholdersBasic',
    'ProfitLoss',
    'NetIncomeLossAttributableToParent',
  ],

  FinancialMetric.earningsPerShareBasic: [
    'EarningsPerShareBasic',
  ],

  FinancialMetric.earningsPerShareDiluted: [
    'EarningsPerShareDiluted',
  ],

  FinancialMetric.researchAndDevelopment: [
    'ResearchAndDevelopmentExpense',
  ],

  FinancialMetric.costOfRevenue: [
    'CostOfRevenue',
    'CostOfGoodsAndServicesSold',
    'CostOfGoodsSold',
  ],

  // Balance Sheet
  FinancialMetric.totalAssets: [
    'Assets',
  ],

  FinancialMetric.totalLiabilities: [
    'Liabilities',
    'LiabilitiesAndStockholdersEquity', // Fallback, subtract equity
  ],

  FinancialMetric.stockholdersEquity: [
    'StockholdersEquity',
    'StockholdersEquityIncludingPortionAttributableToNoncontrollingInterest',
  ],

  FinancialMetric.cashAndEquivalents: [
    'CashAndCashEquivalentsAtCarryingValue',
    'CashCashEquivalentsRestrictedCashAndRestrictedCashEquivalents',
    'Cash',
  ],

  FinancialMetric.currentAssets: [
    'AssetsCurrent',
  ],

  FinancialMetric.currentLiabilities: [
    'LiabilitiesCurrent',
  ],

  FinancialMetric.longTermDebt: [
    'LongTermDebt',
    'LongTermDebtNoncurrent',
  ],

  // Cash Flow
  FinancialMetric.operatingCashFlow: [
    'NetCashProvidedByUsedInOperatingActivities',
    'NetCashProvidedByUsedInOperatingActivitiesContinuingOperations',
  ],

  FinancialMetric.investingCashFlow: [
    'NetCashProvidedByUsedInInvestingActivities',
    'NetCashProvidedByUsedInInvestingActivitiesContinuingOperations',
  ],

  FinancialMetric.financingCashFlow: [
    'NetCashProvidedByUsedInFinancingActivities',
    'NetCashProvidedByUsedInFinancingActivitiesContinuingOperations',
  ],

  FinancialMetric.dividendsPaid: [
    'PaymentsOfDividends',
    'PaymentsOfDividendsCommonStock',
    'PaymentsOfOrdinaryDividends',
    'DividendsPaid',
  ],

  // Balance Sheet - Non-current Liabilities
  FinancialMetric.nonCurrentLiabilities: [
    'LiabilitiesNoncurrent',
    'LiabilitiesOtherThanLongtermDebtNoncurrent',
  ],

  // Other
  FinancialMetric.sharesOutstanding: [
    'CommonStockSharesOutstanding',
    'WeightedAverageNumberOfSharesOutstandingBasic',
  ],

  FinancialMetric.dividendsPerShare: [
    'CommonStockDividendsPerShareDeclared',
    'CommonStockDividendsPerShareCashPaid',
  ],
};

/// Gets the appropriate unit type for a metric.
String getPreferredUnit(FinancialMetric metric) {
  switch (metric) {
    case FinancialMetric.earningsPerShareBasic:
    case FinancialMetric.earningsPerShareDiluted:
    case FinancialMetric.dividendsPerShare:
      return 'USD/shares';
    case FinancialMetric.sharesOutstanding:
      return 'shares';
    default:
      return 'USD';
  }
}
