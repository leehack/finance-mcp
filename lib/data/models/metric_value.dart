import 'fiscal_period.dart';

/// A single financial metric value with metadata.
class FinancialMetricValue {
  const FinancialMetricValue({
    required this.value,
    required this.unit,
    required this.startDate,
    required this.endDate,
    required this.fiscalPeriod,
    this.form,
    this.accessionNumber,
  });
  final double value;
  final String unit; // 'USD', 'USD/shares', 'shares', 'pure'
  final DateTime startDate;
  final DateTime endDate;
  final FiscalPeriod fiscalPeriod;
  final String? form; // '10-K', '10-Q'
  final String? accessionNumber;

  Map<String, dynamic> toJson() => {
        'value': value,
        'unit': unit,
        'startDate': startDate.toIso8601String().split('T')[0],
        'endDate': endDate.toIso8601String().split('T')[0],
        'fiscalYear': fiscalPeriod.year,
        'fiscalPeriod': fiscalPeriod.period,
        if (form != null) 'form': form,
      };
}
