import 'financial_statements.dart';
import 'fiscal_period.dart';
import 'metric_history.dart';

/// Complete financial data for a company.
class CompanyFinancials {
  const CompanyFinancials({
    required this.ticker,
    required this.cik,
    required this.metrics,
    required this.fetchedAt,
    this.companyName,
    this.statements = const {},
  });
  final String ticker;
  final int cik;
  final String? companyName;

  /// Historical metric data (backward compatible).
  final Map<FinancialMetric, MetricHistory> metrics;

  /// Financial statements organized by fiscal period.
  final Map<FiscalPeriod, FinancialStatements> statements;
  final DateTime fetchedAt;

  /// Get history for a specific metric.
  MetricHistory? operator [](FinancialMetric metric) => metrics[metric];

  /// Get financial statements for a specific period.
  FinancialStatements? getStatement(FiscalPeriod period) => statements[period];

  /// Get all available fiscal periods with statements.
  List<FiscalPeriod> get availablePeriods {
    final periods = statements.keys.toList()
      ..sort((a, b) {
        final yearCmp = b.year.compareTo(a.year);
        if (yearCmp != 0) return yearCmp;
        return b.period.compareTo(a.period);
      });
    return periods;
  }

  /// Get all available years of data.
  Set<int> get availableYears {
    final years = <int>{};
    for (final history in metrics.values) {
      for (final value in history.values) {
        years.add(value.fiscalPeriod.year);
      }
    }
    return years;
  }

  /// Get annual statements sorted by year (newest first).
  List<FinancialStatements> get annualStatements {
    return statements.entries
        .where((e) => e.key.isAnnual)
        .map((e) => e.value)
        .toList()
      ..sort((a, b) => b.fiscalPeriod.year.compareTo(a.fiscalPeriod.year));
  }

  /// Get annual Return on Capital values for all available years.
  /// Returns list of ROC values sorted by year (oldest first for trend analysis).
  List<double> get annualROCs {
    final rocs = <double>[];
    for (final stmt in annualStatements.reversed) {
      final roc = stmt.returnOnCapital;
      if (roc != null) {
        rocs.add(roc);
      }
    }
    return rocs;
  }

  /// Median Return on Capital across all annual periods.
  /// Useful as a conservative growth rate estimate for DCF valuation.
  double? get medianROC {
    final rocs = annualROCs;
    if (rocs.isEmpty) return null;
    rocs.sort();
    final mid = rocs.length ~/ 2;
    if (rocs.length.isOdd) {
      return rocs[mid];
    }
    return (rocs[mid - 1] + rocs[mid]) / 2;
  }

  /// Average Return on Capital across all annual periods.
  double? get averageROC {
    final rocs = annualROCs;
    if (rocs.isEmpty) return null;
    return rocs.reduce((a, b) => a + b) / rocs.length;
  }

  /// Get the range of years available.
  (int, int)? get yearRange {
    final years = availableYears.toList()..sort();
    return years.isEmpty ? null : (years.first, years.last);
  }

  Map<String, dynamic> toJson() => {
        'ticker': ticker,
        'cik': cik,
        if (companyName != null) 'companyName': companyName,
        'fetchedAt': fetchedAt.toIso8601String(),
        'yearRange': yearRange != null
            ? {'start': yearRange!.$1, 'end': yearRange!.$2}
            : null,
        'statements': {
          for (final entry in statements.entries)
            entry.key.toString(): entry.value.toJson(),
        },
        'metrics': {
          for (final entry in metrics.entries)
            entry.key.name: entry.value.toJson(),
        },
      };
}

/// Options for fetching financial data.
class FetchOptions {
  // Specific metrics, default all

  const FetchOptions({
    this.years = 10,
    this.includeQuarterly = true,
    this.metricsToFetch,
  });
  final int? years; // Number of years to fetch, default 10
  final bool includeQuarterly; // Include quarterly data, default true
  final Set<FinancialMetric>? metricsToFetch;

  static const defaultOptions = FetchOptions();
}
