/// Cash flow statement data for a single period.
class CashFlowStatement {
  const CashFlowStatement({
    this.operatingCashFlow,
    this.investingCashFlow,
    this.financingCashFlow,
    this.dividendsPaid,
  });

  final double? operatingCashFlow;
  final double? investingCashFlow;
  final double? financingCashFlow;
  final double? dividendsPaid;

  /// Free cash flow (operatingCashFlow + investingCashFlow).
  /// Note: investingCashFlow is typically negative for capex.
  double? get freeCashFlow =>
      (operatingCashFlow != null && investingCashFlow != null)
          ? operatingCashFlow! + investingCashFlow!
          : null;

  /// Net change in cash (sum of all cash flows).
  double? get netCashChange {
    if (operatingCashFlow == null &&
        investingCashFlow == null &&
        financingCashFlow == null) {
      return null;
    }
    return (operatingCashFlow ?? 0) +
        (investingCashFlow ?? 0) +
        (financingCashFlow ?? 0);
  }

  Map<String, dynamic> toJson() => {
        if (operatingCashFlow != null) 'operatingCashFlow': operatingCashFlow,
        if (investingCashFlow != null) 'investingCashFlow': investingCashFlow,
        if (financingCashFlow != null) 'financingCashFlow': financingCashFlow,
        if (dividendsPaid != null) 'dividendsPaid': dividendsPaid,
        if (freeCashFlow != null) 'freeCashFlow': freeCashFlow,
        if (netCashChange != null) 'netCashChange': netCashChange,
      };
}
