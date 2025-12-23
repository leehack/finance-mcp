/// Balance sheet data for a single period.
class BalanceSheet {
  const BalanceSheet({
    this.totalAssets,
    this.totalLiabilities,
    this.stockholdersEquity,
    this.cashAndEquivalents,
    this.currentAssets,
    this.currentLiabilities,
    this.nonCurrentLiabilities,
    this.longTermDebt,
  });

  /// Total assets of the company.
  final double? totalAssets;

  /// Total liabilities of the company.
  final double? totalLiabilities;

  /// Total stockholders' equity.
  final double? stockholdersEquity;

  /// Cash and cash equivalents.
  final double? cashAndEquivalents;

  /// Current assets (assets expected to be sold/used within one year).
  final double? currentAssets;

  /// Current liabilities (obligations due within one year).
  final double? currentLiabilities;

  /// Non-current liabilities (long-term obligations).
  final double? nonCurrentLiabilities;

  /// Long-term debt.
  final double? longTermDebt;

  /// Current ratio (currentAssets / currentLiabilities).
  double? get currentRatio => (currentAssets != null &&
          currentLiabilities != null &&
          currentLiabilities != 0)
      ? currentAssets! / currentLiabilities!
      : null;

  /// Debt to equity ratio (longTermDebt / stockholdersEquity).
  double? get debtToEquity => (longTermDebt != null &&
          stockholdersEquity != null &&
          stockholdersEquity != 0)
      ? longTermDebt! / stockholdersEquity!
      : null;

  Map<String, dynamic> toJson() => {
        if (totalAssets != null) 'totalAssets': totalAssets,
        if (totalLiabilities != null) 'totalLiabilities': totalLiabilities,
        if (stockholdersEquity != null)
          'stockholdersEquity': stockholdersEquity,
        if (cashAndEquivalents != null)
          'cashAndEquivalents': cashAndEquivalents,
        if (currentAssets != null) 'currentAssets': currentAssets,
        if (currentLiabilities != null)
          'currentLiabilities': currentLiabilities,
        if (nonCurrentLiabilities != null)
          'nonCurrentLiabilities': nonCurrentLiabilities,
        if (longTermDebt != null) 'longTermDebt': longTermDebt,
        if (currentRatio != null) 'currentRatio': currentRatio,
        if (debtToEquity != null) 'debtToEquity': debtToEquity,
      };
}
