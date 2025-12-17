/// Income statement data for a single period.
class IncomeStatement {
  const IncomeStatement({
    this.revenue,
    this.grossProfit,
    this.operatingIncome,
    this.netIncome,
    this.earningsPerShareBasic,
    this.earningsPerShareDiluted,
    this.researchAndDevelopment,
    this.costOfRevenue,
  });

  final double? revenue;
  final double? grossProfit;
  final double? operatingIncome;
  final double? netIncome;
  final double? earningsPerShareBasic;
  final double? earningsPerShareDiluted;
  final double? researchAndDevelopment;
  final double? costOfRevenue;

  /// Gross margin as a percentage (grossProfit / revenue).
  double? get grossMargin =>
      (revenue != null && revenue != 0 && grossProfit != null)
          ? grossProfit! / revenue!
          : null;

  /// Operating margin as a percentage (operatingIncome / revenue).
  double? get operatingMargin =>
      (revenue != null && revenue != 0 && operatingIncome != null)
          ? operatingIncome! / revenue!
          : null;

  /// Net margin as a percentage (netIncome / revenue).
  double? get netMargin =>
      (revenue != null && revenue != 0 && netIncome != null)
          ? netIncome! / revenue!
          : null;

  Map<String, dynamic> toJson() => {
        if (revenue != null) 'revenue': revenue,
        if (grossProfit != null) 'grossProfit': grossProfit,
        if (operatingIncome != null) 'operatingIncome': operatingIncome,
        if (netIncome != null) 'netIncome': netIncome,
        if (earningsPerShareBasic != null)
          'earningsPerShareBasic': earningsPerShareBasic,
        if (earningsPerShareDiluted != null)
          'earningsPerShareDiluted': earningsPerShareDiluted,
        if (researchAndDevelopment != null)
          'researchAndDevelopment': researchAndDevelopment,
        if (costOfRevenue != null) 'costOfRevenue': costOfRevenue,
        if (grossMargin != null) 'grossMargin': grossMargin,
        if (operatingMargin != null) 'operatingMargin': operatingMargin,
        if (netMargin != null) 'netMargin': netMargin,
      };
}
