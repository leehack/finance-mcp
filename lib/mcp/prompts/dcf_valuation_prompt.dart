/// Prompt for performing a DCF (Discounted Cash Flow) valuation.
library;

import 'package:mcp_dart/mcp_dart.dart';

import 'base_prompt.dart';

/// Generates a structured prompt for DCF valuation analysis.
///
/// This prompt guides the LLM through a complete DCF valuation:
/// - Historical free cash flow analysis
/// - Growth rate assumptions
/// - WACC calculation
/// - Terminal value estimation
/// - Sensitivity analysis
/// - Fair value conclusion
class DcfValuationPrompt extends BasePrompt {
  @override
  String get name => 'dcf_valuation';

  @override
  String get title => 'DCF Valuation';

  @override
  String get description =>
      'Generate a discounted cash flow (DCF) valuation prompt for a company. '
      'Provides a structured framework for calculating intrinsic value using '
      'FCF projections, WACC, and terminal value methods.';

  @override
  Map<String, PromptArgumentDefinition>? get argsSchema => {
        'ticker': PromptArgumentDefinition(
          description: 'Stock ticker symbol (e.g., AAPL, MSFT, GOOGL)',
          required: true,
        ),
        'projection_years': PromptArgumentDefinition(
          description:
              'Number of years to project (default: 10). Use 5 for less predictable businesses.',
        ),
        'terminal_method': PromptArgumentDefinition(
          description:
              'Terminal value method: "perpetuity" (Gordon Growth) or "exit_multiple"',
        ),
      };

  @override
  GetPromptResult getPrompt(Map<String, dynamic>? args) {
    final ticker = (args?['ticker'] as String?)?.toUpperCase() ?? '[TICKER]';
    final projectionYears =
        int.tryParse(args?['projection_years']?.toString() ?? '') ?? 10;
    final terminalMethod = args?['terminal_method'] as String? ?? 'perpetuity';

    final terminalMethodText = terminalMethod.toLowerCase() == 'exit_multiple'
        ? 'Exit Multiple Method'
        : 'Perpetuity Growth (Gordon Growth Model)';

    return GetPromptResult(
      description: 'DCF valuation framework for $ticker',
      messages: [
        PromptMessage(
          role: PromptMessageRole.user,
          content: TextContent(
            text: '''Perform a Discounted Cash Flow (DCF) valuation for $ticker.

**Valuation Parameters:**
- Projection Period: $projectionYears years
- Terminal Value Method: $terminalMethodText

---

## DCF Valuation Framework

### Step 1: Historical Free Cash Flow Analysis

Using the financial data, calculate and analyze:

**Historical FCF (last 5 years):**
| Year | Operating CF | CapEx | Free Cash Flow | FCF Margin |
|------|--------------|-------|----------------|------------|
| | | | | |

**FCF Quality Assessment:**
- Is FCF consistent and growing?
- How does FCF compare to net income? (FCF conversion)
- Any significant working capital swings?
- CapEx: Maintenance vs. Growth split (if identifiable)

### Step 2: Revenue & FCF Projections

**Revenue Growth Assumptions:**
| Period | Growth Rate | Rationale |
|--------|-------------|-----------|
| Years 1-3 | | Near-term visibility |
| Years 4-7 | | Normalization phase |
| Years 8-$projectionYears | | Mature growth |

**FCF Margin Assumptions:**
| Period | FCF Margin | Rationale |
|--------|------------|-----------|
| Current | | Actual |
| Target (Year $projectionYears) | | Industry/company maturity |

**Projected Free Cash Flows:**
| Year | Revenue | FCF Margin | Free Cash Flow |
|------|---------|------------|----------------|
${List.generate(projectionYears, (i) => '| ${i + 1} | | | |').join('\n')}

### Step 3: Discount Rate (WACC)

**Cost of Equity (CAPM):**
- Risk-free rate: ___% (10-year Treasury)
- Beta: ___ (levered)
- Equity risk premium: ___% (typically 4-6%)
- Cost of Equity = Rf + β × ERP = ___%

**Cost of Debt:**
- Pre-tax cost of debt: ___%
- Tax rate: ___%
- After-tax cost of debt: ___%

**WACC Calculation:**
| Component | Weight | Cost | Weighted Cost |
|-----------|--------|------|---------------|
| Equity | | | |
| Debt | | | |
| **WACC** | 100% | | **____%** |

### Step 4: Terminal Value

${terminalMethod.toLowerCase() == 'exit_multiple' ? r'''
**Exit Multiple Method:**
- Terminal Year EBITDA: $___
- Exit EV/EBITDA Multiple: ___x (comparable transactions)
- Terminal Value: $___
''' : r'''
**Perpetuity Growth Method:**
- Terminal Year FCF: $___
- Perpetual Growth Rate: ___% (should be ≤ nominal GDP growth)
- Terminal Value = FCF × (1 + g) / (WACC - g) = $___
'''}

### Step 5: Present Value Calculation

**DCF Summary:**
| Component | Value |
|-----------|-------|
| PV of Projected FCFs | \$___ |
| PV of Terminal Value | \$___ |
| **Enterprise Value** | **\$___** |
| Less: Net Debt | (\$___) |
| **Equity Value** | **\$___** |
| Shares Outstanding | ___ |
| **Intrinsic Value/Share** | **\$___** |

**Current Price:** \$___
**Upside/Downside:** ____%

### Step 6: Sensitivity Analysis

**Sensitivity Table (WACC vs. Terminal Growth):**
| | WACC -1% | WACC Base | WACC +1% |
|---|----------|-----------|----------|
| TG +0.5% | \$___ | \$___ | \$___ |
| TG Base | \$___ | **\$___** | \$___ |
| TG -0.5% | \$___ | \$___ | \$___ |

### Step 7: Valuation Conclusion

**Fair Value Range:** \$___ to \$___ per share
**Base Case:** \$___ per share
**Margin of Safety at Current Price:** ____%

**Key Assumptions Driving Value:**
1. 
2. 
3. 

**Valuation Risks:**
- 

---

Please use the get_company_info and get_financial_statements tools to retrieve the historical financial data needed for this DCF analysis.''',
          ),
        ),
      ],
    );
  }
}
