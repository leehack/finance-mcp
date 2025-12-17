import 'dart:math' show pow;

import 'financial_statements.dart';

/// DCF (Discounted Cash Flow) valuation parameters and calculator.
class DcfValuation {
  const DcfValuation({
    required this.freeCashFlow,
    required this.sharesOutstanding,
    this.growthRate = 0.10,
    this.terminalGrowthRate = 0.025,
    this.discountRate = 0.10,
    this.projectionYears = 10,
  });

  /// Most recent annual free cash flow.
  final double freeCashFlow;

  /// Number of shares outstanding.
  final double sharesOutstanding;

  /// Expected annual FCF growth rate (default 10%).
  final double growthRate;

  /// Long-term growth rate for terminal value (default 2.5%).
  final double terminalGrowthRate;

  /// Discount rate / WACC (default 10%).
  final double discountRate;

  /// Number of years to project (default 10).
  final int projectionYears;

  /// Calculate intrinsic value using DCF model.
  /// Returns total enterprise value.
  double get enterpriseValue {
    var presentValue = 0.0;
    var projectedFcf = freeCashFlow;

    // Sum of discounted projected cash flows
    for (var year = 1; year <= projectionYears; year++) {
      projectedFcf *= 1 + growthRate;
      final discountFactor = 1 / pow(1 + discountRate, year);
      presentValue += projectedFcf * discountFactor;
    }

    // Terminal value using Gordon Growth Model
    final terminalFcf = projectedFcf * (1 + terminalGrowthRate);
    final terminalValue = terminalFcf / (discountRate - terminalGrowthRate);
    final discountedTerminal =
        terminalValue / pow(1 + discountRate, projectionYears);

    return presentValue + discountedTerminal;
  }

  /// Intrinsic value per share.
  double get intrinsicValuePerShare {
    if (sharesOutstanding == 0) return 0;
    return enterpriseValue / sharesOutstanding;
  }

  /// Margin of safety calculation.
  /// Returns percentage below intrinsic value (positive = undervalued).
  double marginOfSafety(double currentPrice) {
    if (currentPrice == 0) return 0;
    return (intrinsicValuePerShare - currentPrice) / intrinsicValuePerShare;
  }

  /// Create DCF valuation from FinancialStatements.
  static DcfValuation? fromStatements(
    FinancialStatements statements, {
    double? growthRate,
    double terminalGrowthRate = 0.025,
    double discountRate = 0.10,
    int projectionYears = 10,
  }) {
    final fcf = statements.cashFlowStatement.freeCashFlow;
    final shares = statements.sharesOutstanding;

    if (fcf == null || shares == null || fcf <= 0) return null;

    return DcfValuation(
      freeCashFlow: fcf,
      sharesOutstanding: shares,
      growthRate: growthRate ?? 0.10,
      terminalGrowthRate: terminalGrowthRate,
      discountRate: discountRate,
      projectionYears: projectionYears,
    );
  }

  Map<String, dynamic> toJson() => {
        'freeCashFlow': freeCashFlow,
        'sharesOutstanding': sharesOutstanding,
        'growthRate': growthRate,
        'terminalGrowthRate': terminalGrowthRate,
        'discountRate': discountRate,
        'projectionYears': projectionYears,
        'enterpriseValue': enterpriseValue,
        'intrinsicValuePerShare': intrinsicValuePerShare,
      };
}
