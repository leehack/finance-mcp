/// Concept mapping from standardized metrics to SEC XBRL tags.
///
/// Based on comprehensive analysis of US GAAP taxonomy and SEC EDGAR data
/// across diverse sectors: tech, finance, healthcare, retail, energy, utilities.
/// Tags are ordered by priority - more common/reliable tags first.
library;

import '../models/metric_history.dart';

/// Maps standardized metrics to possible SEC XBRL concept tags.
/// Tags are ordered by priority - more common/reliable tags first.
const Map<FinancialMetric, List<String>> conceptMappings = {
  // ============= INCOME STATEMENT =============

  FinancialMetric.revenue: [
    // ASC 606 (Revenue from Contracts) - Primary for modern filings
    'RevenueFromContractWithCustomerExcludingAssessedTax',
    'RevenueFromContractWithCustomerIncludingAssessedTax',
    // General revenue tags
    'Revenues',
    'Revenue',
    'NetRevenues',
    'TotalRevenues',
    // Sales-based (retail, manufacturing)
    'SalesRevenueNet',
    'SalesRevenueGoodsNet',
    'SalesRevenueServicesNet',
    'NetSales',
    // Industry-specific
    'RevenuesNetOfInterestExpense', // Banks
    'InterestAndDividendIncomeOperating', // Banks, Insurance
    'InterestIncomeExpenseNet', // Financial services
    'PremiumsEarnedNet', // Insurance
    'TotalRevenuesAndOtherIncome',
    'OperatingRevenue', // Utilities
    'RegulatedAndUnregulatedOperatingRevenue', // Utilities
    'ElectricUtilityRevenue', // Electric utilities
    'OilAndGasRevenue', // Energy
    'RealEstateRevenueNet', // REITs
    'HealthCareOrganizationPatientServiceRevenue', // Healthcare
  ],

  FinancialMetric.grossProfit: [
    'GrossProfit',
    'GrossProfitLoss',
  ],

  FinancialMetric.operatingIncome: [
    'OperatingIncomeLoss',
    'IncomeLossFromContinuingOperationsBeforeIncomeTaxesExtraordinaryItemsNoncontrollingInterest',
    'IncomeLossFromContinuingOperationsBeforeIncomeTaxesMinorityInterestAndIncomeLossFromEquityMethodInvestments',
    'IncomeLossFromContinuingOperationsBeforeInterestExpenseInterestIncomeIncomeTaxesExtraordinaryItemsNoncontrollingInterestsNet',
    'IncomeLossFromContinuingOperations',
    'OperatingProfit',
  ],

  FinancialMetric.netIncome: [
    'NetIncomeLoss',
    'NetIncomeLossAvailableToCommonStockholdersBasic',
    'NetIncomeLossAttributableToParent',
    'ProfitLoss',
    'NetIncomeLossAvailableToCommonStockholdersDiluted',
    'ComprehensiveIncomeNetOfTax',
    'ComprehensiveIncomeNetOfTaxAttributableToParent',
  ],

  FinancialMetric.earningsPerShareBasic: [
    'EarningsPerShareBasic',
    'IncomeLossFromContinuingOperationsPerBasicShare',
    'NetIncomeLossPerShareBasic',
  ],

  FinancialMetric.earningsPerShareDiluted: [
    'EarningsPerShareDiluted',
    'IncomeLossFromContinuingOperationsPerDilutedShare',
    'NetIncomeLossPerShareDiluted',
  ],

  FinancialMetric.researchAndDevelopment: [
    'ResearchAndDevelopmentExpense',
    'ResearchAndDevelopmentExpenseExcludingAcquiredInProcessCost',
    'ResearchAndDevelopmentExpenseSoftwareExcludingAcquiredInProcessCost',
  ],

  FinancialMetric.costOfRevenue: [
    'CostOfRevenue',
    'CostOfGoodsAndServicesSold',
    'CostOfGoodsSold',
    'CostOfGoodsAndServiceExcludingDepreciationDepletionAndAmortization',
    'CostOfServices',
    'CostOfSalesMember',
  ],

  // ============= BALANCE SHEET =============

  FinancialMetric.totalAssets: [
    'Assets',
    'AssetsNet',
  ],

  FinancialMetric.totalLiabilities: [
    'Liabilities',
    'LiabilitiesTotal',
  ],

  FinancialMetric.stockholdersEquity: [
    'StockholdersEquity',
    'StockholdersEquityIncludingPortionAttributableToNoncontrollingInterest',
    'EquityAttributableToParent',
    'TotalEquity',
    'MembersEquity', // Partnerships, LLCs
    'PartnersCapital', // Partnerships
  ],

  FinancialMetric.cashAndEquivalents: [
    'CashAndCashEquivalentsAtCarryingValue',
    'CashCashEquivalentsRestrictedCashAndRestrictedCashEquivalents',
    'CashCashEquivalentsAndShortTermInvestments',
    'Cash',
    'CashAndCashEquivalentsAtCarryingValueIncludingDiscontinuedOperations',
    'CashEquivalentsAtCarryingValue',
  ],

  FinancialMetric.currentAssets: [
    'AssetsCurrent',
    'AssetsCurrentTotal',
  ],

  FinancialMetric.currentLiabilities: [
    'LiabilitiesCurrent',
    'LiabilitiesCurrentTotal',
  ],

  FinancialMetric.longTermDebt: [
    'LongTermDebt',
    'LongTermDebtNoncurrent',
    'LongTermDebtAndCapitalLeaseObligations',
    'DebtAndCapitalLeaseObligations',
    'LongTermDebtAndCapitalLeaseObligationsIncludingCurrentMaturities',
    'NotesPayable',
    'SeniorNotes',
    'ConvertibleDebt',
    'SecuredDebt',
    'UnsecuredDebt',
  ],

  FinancialMetric.nonCurrentLiabilities: [
    'LiabilitiesNoncurrent',
    'LiabilitiesOtherThanLongtermDebtNoncurrent',
    'NoncurrentLiabilities',
  ],

  // ============= CASH FLOW STATEMENT =============

  FinancialMetric.operatingCashFlow: [
    'NetCashProvidedByUsedInOperatingActivities',
    'NetCashProvidedByUsedInOperatingActivitiesContinuingOperations',
    'CashFlowsFromUsedInOperatingActivities',
  ],

  FinancialMetric.investingCashFlow: [
    'NetCashProvidedByUsedInInvestingActivities',
    'NetCashProvidedByUsedInInvestingActivitiesContinuingOperations',
    'CashFlowsFromUsedInInvestingActivities',
  ],

  FinancialMetric.financingCashFlow: [
    'NetCashProvidedByUsedInFinancingActivities',
    'NetCashProvidedByUsedInFinancingActivitiesContinuingOperations',
    'CashFlowsFromUsedInFinancingActivities',
  ],

  FinancialMetric.capitalExpenditures: [
    'PaymentsToAcquirePropertyPlantAndEquipment',
    'PaymentsToAcquireProductiveAssets',
    'PaymentsForCapitalImprovements',
    'CapitalExpendituresIncurredButNotYetPaid',
    'PaymentsToAcquireAndDevelopRealEstate', // REITs
    'PaymentsToAcquireOtherPropertyPlantAndEquipment',
    'PaymentsForProceedsFromProductiveAssets',
    'PurchaseOfPropertyPlantAndEquipment',
  ],

  FinancialMetric.depreciationAmortization: [
    'DepreciationDepletionAndAmortization',
    'DepreciationAndAmortization',
    'Depreciation',
    'DepreciationNonproduction',
    'AmortizationOfIntangibleAssets',
    'DepreciationAmortizationAndAccretionNet',
  ],

  FinancialMetric.dividendsPaid: [
    'PaymentsOfDividends',
    'PaymentsOfDividendsCommonStock',
    'PaymentsOfOrdinaryDividends',
    'DividendsPaid',
    'PaymentsOfDividendsMinorityInterest',
    'Dividends',
    'DividendsCash',
  ],

  // ============= OTHER =============

  FinancialMetric.sharesOutstanding: [
    'CommonStockSharesOutstanding',
    'WeightedAverageNumberOfSharesOutstandingBasic',
    'WeightedAverageNumberOfDilutedSharesOutstanding',
    'CommonStockSharesIssued',
    'SharesOutstanding',
  ],

  FinancialMetric.dividendsPerShare: [
    'CommonStockDividendsPerShareDeclared',
    'CommonStockDividendsPerShareCashPaid',
    'DividendsPerShare',
    'DividendsPerShareCashPaid',
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
