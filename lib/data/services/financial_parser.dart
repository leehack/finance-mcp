/// Enhanced financial data parser.
///
/// Extracts standardized financial metrics from SEC XBRL data,
/// handling the variation in concept tags across different companies.
library;

import '../constants/concept_mappings.dart';
import '../models/balance_sheet.dart';
import '../models/cash_flow_statement.dart';
import '../models/company_financials.dart';
import '../models/financial_statements.dart';
import '../models/fiscal_period.dart';
import '../models/income_statement.dart';
import '../models/metric_history.dart';
import '../models/metric_value.dart';

/// Parser for SEC XBRL financial data.
///
/// Converts raw SEC EDGAR company facts into structured financial models.
class FinancialParser {
  /// Parse company facts and extract all metrics for specified years.
  CompanyFinancials parseCompanyFacts({
    required String ticker,
    required int cik,
    required Map<String, dynamic> facts,
    FetchOptions options = FetchOptions.defaultOptions,
  }) {
    final usGaap = facts['facts']?['us-gaap'] as Map<String, dynamic>?;
    final companyName = facts['entityName'] as String?;

    if (usGaap == null) {
      return CompanyFinancials(
        ticker: ticker,
        cik: cik,
        companyName: companyName,
        metrics: {},
        fetchedAt: DateTime.now(),
      );
    }

    final metricsToFetch =
        options.metricsToFetch ?? FinancialMetric.values.toSet();
    final metrics = <FinancialMetric, MetricHistory>{};

    for (final metric in metricsToFetch) {
      final history = _extractMetricHistory(
        usGaap: usGaap,
        metric: metric,
        years: options.years,
        includeQuarterly: options.includeQuarterly,
      );

      if (history.values.isNotEmpty) {
        metrics[metric] = history;
      }
    }

    // Build statements map from metrics
    final statements = _buildStatements(metrics);

    return CompanyFinancials(
      ticker: ticker,
      cik: cik,
      companyName: companyName,
      metrics: metrics,
      statements: statements,
      fetchedAt: DateTime.now(),
    );
  }

  /// Build FinancialStatements for each unique fiscal period.
  Map<FiscalPeriod, FinancialStatements> _buildStatements(
    Map<FinancialMetric, MetricHistory> metrics,
  ) {
    // Collect all unique fiscal periods
    final allPeriods = <FiscalPeriod>{};
    for (final history in metrics.values) {
      for (final value in history.values) {
        allPeriods.add(value.fiscalPeriod);
      }
    }

    // Helper to get latest value for a metric in a period
    double? getValue(FinancialMetric metric, FiscalPeriod period) {
      final history = metrics[metric];
      if (history == null) return null;
      final match =
          history.values.where((v) => v.fiscalPeriod == period).toList();
      if (match.isEmpty) return null;
      // Return the most recent filing for this period
      match.sort((a, b) => b.endDate.compareTo(a.endDate));
      return match.first.value;
    }

    // Build statements for each period
    final statements = <FiscalPeriod, FinancialStatements>{};

    for (final period in allPeriods) {
      final incomeStatement = IncomeStatement(
        revenue: getValue(FinancialMetric.revenue, period),
        grossProfit: getValue(FinancialMetric.grossProfit, period),
        operatingIncome: getValue(FinancialMetric.operatingIncome, period),
        netIncome: getValue(FinancialMetric.netIncome, period),
        earningsPerShareBasic:
            getValue(FinancialMetric.earningsPerShareBasic, period),
        earningsPerShareDiluted:
            getValue(FinancialMetric.earningsPerShareDiluted, period),
        researchAndDevelopment:
            getValue(FinancialMetric.researchAndDevelopment, period),
        costOfRevenue: getValue(FinancialMetric.costOfRevenue, period),
      );

      final balanceSheet = BalanceSheet(
        totalAssets: getValue(FinancialMetric.totalAssets, period),
        totalLiabilities: getValue(FinancialMetric.totalLiabilities, period),
        stockholdersEquity:
            getValue(FinancialMetric.stockholdersEquity, period),
        cashAndEquivalents:
            getValue(FinancialMetric.cashAndEquivalents, period),
        currentAssets: getValue(FinancialMetric.currentAssets, period),
        currentLiabilities:
            getValue(FinancialMetric.currentLiabilities, period),
        nonCurrentLiabilities:
            getValue(FinancialMetric.nonCurrentLiabilities, period),
        longTermDebt: getValue(FinancialMetric.longTermDebt, period),
      );

      final cashFlowStatement = CashFlowStatement(
        operatingCashFlow: getValue(FinancialMetric.operatingCashFlow, period),
        investingCashFlow: getValue(FinancialMetric.investingCashFlow, period),
        financingCashFlow: getValue(FinancialMetric.financingCashFlow, period),
        dividendsPaid: getValue(FinancialMetric.dividendsPaid, period),
      );

      statements[period] = FinancialStatements(
        fiscalPeriod: period,
        incomeStatement: incomeStatement,
        balanceSheet: balanceSheet,
        cashFlowStatement: cashFlowStatement,
        sharesOutstanding: getValue(FinancialMetric.sharesOutstanding, period),
        dividendsPerShare: getValue(FinancialMetric.dividendsPerShare, period),
      );
    }

    return statements;
  }

  /// Extract history for a single metric.
  MetricHistory _extractMetricHistory({
    required Map<String, dynamic> usGaap,
    required FinancialMetric metric,
    int? years,
    bool includeQuarterly = true,
  }) {
    final conceptTags = conceptMappings[metric] ?? [];
    final preferredUnit = getPreferredUnit(metric);
    final values = <FinancialMetricValue>[];

    // Try each concept tag in priority order
    for (final tag in conceptTags) {
      if (!usGaap.containsKey(tag)) continue;

      final data = usGaap[tag] as Map<String, dynamic>;
      final units = data['units'] as Map<String, dynamic>?;
      if (units == null) continue;

      // Find the appropriate unit key
      String? unitKey;
      if (preferredUnit == 'USD/shares' && units.containsKey('USD/shares')) {
        unitKey = 'USD/shares';
      } else if (preferredUnit == 'shares' && units.containsKey('shares')) {
        unitKey = 'shares';
      } else if (units.containsKey('USD')) {
        unitKey = 'USD';
      } else if (preferredUnit == 'shares' && units.containsKey('pure')) {
        unitKey = 'pure'; // Sometimes shares are reported as pure numbers
      }

      if (unitKey == null) continue;

      final rawValues = units[unitKey] as List<dynamic>;

      for (final raw in rawValues) {
        final fy = raw['fy'] as int?;
        final fp = raw['fp'] as String?;
        final val = raw['val'];
        final end = raw['end'] as String?;
        final start = raw['start'] as String?;
        final form = raw['form'] as String?;
        final accn = raw['accn'] as String?;

        if (fy == null || fp == null || val == null || end == null) continue;

        // Skip if outside year range
        if (years != null) {
          final currentYear = DateTime.now().year;
          if (fy < currentYear - years) continue;
        }

        // Skip quarterly if not requested
        if (!includeQuarterly && fp != 'FY') continue;

        // Parse value as double
        final numericValue =
            val is num ? val.toDouble() : double.tryParse(val.toString());
        if (numericValue == null) continue;

        values.add(
          FinancialMetricValue(
            value: numericValue,
            unit: unitKey,
            startDate:
                start != null ? DateTime.parse(start) : DateTime.parse(end),
            endDate: DateTime.parse(end),
            fiscalPeriod: FiscalPeriod(year: fy, period: fp),
            form: form,
            accessionNumber: accn,
          ),
        );
      }

      // If we found values with this tag, use them (priority order)
      if (values.isNotEmpty) break;
    }

    // Deduplicate by fiscal period (keep latest filing)
    final dedupedValues = _deduplicateByPeriod(values);

    return MetricHistory(metric: metric, values: dedupedValues);
  }

  /// Deduplicate values by fiscal period, keeping the most recent filing.
  List<FinancialMetricValue> _deduplicateByPeriod(
    List<FinancialMetricValue> values,
  ) {
    final byPeriod = <FiscalPeriod, FinancialMetricValue>{};

    for (final value in values) {
      final existing = byPeriod[value.fiscalPeriod];
      if (existing == null || value.endDate.isAfter(existing.endDate)) {
        byPeriod[value.fiscalPeriod] = value;
      }
    }

    final result = byPeriod.values.toList()
      ..sort((a, b) => b.endDate.compareTo(a.endDate)); // Newest first
    return result;
  }

  /// Get a summary of available data for a company.
  Map<String, dynamic> getDataSummary(CompanyFinancials financials) {
    final metricCoverage = <String, Map<String, dynamic>>{};

    for (final entry in financials.metrics.entries) {
      final metric = entry.key;
      final history = entry.value;

      final annualYears =
          history.annualValues.map((v) => v.fiscalPeriod.year).toSet();
      final quarterlyCount = history.quarterlyValues.length;

      metricCoverage[metric.name] = {
        'displayName': metric.displayName,
        'annualYears': annualYears.toList()..sort(),
        'quarterlyDataPoints': quarterlyCount,
        'latestValue': history.latest?.value,
        'latestPeriod': history.latest?.fiscalPeriod.toString(),
      };
    }

    return {
      'ticker': financials.ticker,
      'companyName': financials.companyName,
      'yearRange': financials.yearRange,
      'metricsAvailable': financials.metrics.length,
      'metrics': metricCoverage,
    };
  }
}
