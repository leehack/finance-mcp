/// Cash flow statement data for a single period.
class CashFlowStatement {
  const CashFlowStatement({
    this.operatingCashFlow,
    this.investingCashFlow,
    this.financingCashFlow,
    this.capitalExpenditures,
    this.depreciationAmortization,
    this.dividendsPaid,
  });

  final double? operatingCashFlow;
  final double? investingCashFlow;
  final double? financingCashFlow;

  /// Capital expenditures (payments for PP&E).
  /// Typically reported as a negative number (cash outflow).
  final double? capitalExpenditures;

  /// Depreciation and amortization (non-cash expense).
  /// Used for quality of earnings analysis.
  final double? depreciationAmortization;

  final double? dividendsPaid;

  /// Free cash flow calculated as:
  /// - If CapEx available: Operating Cash Flow - |CapEx|
  /// - Fallback: Operating Cash Flow + Investing Cash Flow
  ///
  /// Note: CapEx is typically negative (outflow), so we use absolute value.
  double? get freeCashFlow {
    if (operatingCashFlow == null) return null;

    // Prefer explicit CapEx calculation for accuracy
    if (capitalExpenditures != null) {
      // CapEx is typically negative, so we subtract the absolute value
      return operatingCashFlow! - capitalExpenditures!.abs();
    }

    // Fallback to operating + investing (less accurate but still useful)
    if (investingCashFlow != null) {
      return operatingCashFlow! + investingCashFlow!;
    }

    return null;
  }

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

  /// CapEx as percentage of operating cash flow.
  /// Higher values indicate capital-intensive business.
  double? get capexToOperatingCashFlow {
    if (capitalExpenditures == null || operatingCashFlow == null) return null;
    if (operatingCashFlow == 0) return null;
    return capitalExpenditures!.abs() / operatingCashFlow!.abs();
  }

  /// FCF conversion rate (FCF / Operating Cash Flow).
  /// Values closer to 1.0 indicate efficient capital allocation.
  double? get fcfConversionRate {
    if (freeCashFlow == null || operatingCashFlow == null) return null;
    if (operatingCashFlow == 0) return null;
    return freeCashFlow! / operatingCashFlow!;
  }

  Map<String, dynamic> toJson() => {
        if (operatingCashFlow != null) 'operatingCashFlow': operatingCashFlow,
        if (investingCashFlow != null) 'investingCashFlow': investingCashFlow,
        if (financingCashFlow != null) 'financingCashFlow': financingCashFlow,
        if (capitalExpenditures != null)
          'capitalExpenditures': capitalExpenditures,
        if (depreciationAmortization != null)
          'depreciationAmortization': depreciationAmortization,
        if (dividendsPaid != null) 'dividendsPaid': dividendsPaid,
        if (freeCashFlow != null) 'freeCashFlow': freeCashFlow,
        if (netCashChange != null) 'netCashChange': netCashChange,
        if (capexToOperatingCashFlow != null)
          'capexToOperatingCashFlow': capexToOperatingCashFlow,
        if (fcfConversionRate != null) 'fcfConversionRate': fcfConversionRate,
      };
}
