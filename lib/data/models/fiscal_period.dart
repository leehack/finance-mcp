/// Represents a fiscal period (year + quarter).
class FiscalPeriod {
  // 'FY', 'Q1', 'Q2', 'Q3', 'Q4'

  const FiscalPeriod({required this.year, required this.period});
  final int year;
  final String period;

  bool get isAnnual => period == 'FY';
  bool get isQuarterly => period.startsWith('Q');

  @override
  String toString() => '$year-$period';

  @override
  bool operator ==(Object other) =>
      other is FiscalPeriod && other.year == year && other.period == period;

  @override
  int get hashCode => Object.hash(year, period);
}
