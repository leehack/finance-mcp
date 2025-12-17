/// Prompt for performing a comprehensive intrinsic value analysis.
library;

import 'package:mcp_dart/mcp_dart.dart';

import 'base_prompt.dart';

/// Generates a structured prompt for intrinsic value analysis (DCF + Quality).
///
/// This prompt guides the LLM through a complete valuation including:
/// - 5-10 year historical analysis of PE, ROE, and FCF
/// - Quality assessment (Moat, Management, Financial Strength)
/// - 5-year projection of key metrics
/// - Dual valuation methods: DCF and Exit PE
class IntrinsicValuePrompt extends BasePrompt {
  @override
  String get name => 'intrinsic_value';

  @override
  String get title => 'Intrinsic Value Analysis';

  @override
  String get description =>
      'Generate a comprehensive intrinsic value prompt combining DCF and '
      'Quality (PE, ROE) analysis. Requires 5-10 years of history and '
      'projected growth assumptions.';

  @override
  Map<String, PromptArgumentDefinition>? get argsSchema => {
        'ticker': PromptArgumentDefinition(
          description: 'Stock ticker symbol (e.g., AAPL, MSFT)',
          required: true,
        ),
        'history_years': PromptArgumentDefinition(
          description: 'Years of historical data to analyze (default: 10)',
        ),
        'projection_years': PromptArgumentDefinition(
          description: 'Years to project for valuation (default: 5)',
        ),
      };

  @override
  GetPromptResult getPrompt(Map<String, dynamic>? args) {
    final ticker = (args?['ticker'] as String?)?.toUpperCase() ?? '[TICKER]';
    final historyYears =
        int.tryParse(args?['history_years']?.toString() ?? '') ?? 10;
    final projectionYears =
        int.tryParse(args?['projection_years']?.toString() ?? '') ?? 5;

    return GetPromptResult(
      description: 'Intrinsic value analysis for $ticker',
      messages: [
        PromptMessage(
          role: PromptMessageRole.user,
          content: TextContent(
            text:
                '''Perform a comprehensive Intrinsic Value Analysis for $ticker.

**Parameters:**
- Historical Analysis: Past $historyYears years
- Projection Period: Next $projectionYears years

---

## Part 1: Quality & Historical Analysis ($historyYears Years)

### 1. Business Quality (The "Moat")
- **Competitive Advantage:** Is it durable? (Network effect, Switching costs, Brand, Cost advantage)
- **Capital Allocation:** Management's track record (ROIC trends, Buybacks vs. Dividends vs. Acquisitions)

### 2. Historical Financial Performance
Analyze the trend and stability of the following metrics over the past $historyYears years:

**Efficiency & Profitability:**
| Metric | $historyYears-Year Avg | Trend (Growing/Stable/Declining) | Consistency Note |
|--------|----------------|----------------------------------|------------------|
| **ROE** (Return on Equity) | | | Target > 15%? |
| **ROIC** (Return on Capital) | | | > WACC? |
| **Gross Margin** | | | Pricing power? |
| **Operating Margin** | | | Operating leverage? |

**Valuation History:**
- **PE Ratio:** Max: ___, Min: ___, Average: ___
- **FCF Yield:** Average: ___

**Growth:**
- Revenue CAGR ($historyYears yr): ___%
- EPS CAGR ($historyYears yr): ___%
- FCF per Share CAGR ($historyYears yr): ___%

---

## Part 2: Projections & Valuation (Next $projectionYears Years)

### 3. Growth Assumptions
| Metric | Years 1-3 (CAGR) | Years 4-$projectionYears (CAGR) | Rationale |
|--------|------------------|-----------------------|-----------|
| Revenue | | | |
| Earnings / FCF | | | |

### 4. Valuation Method A: Discounted Cash Flow (DCF)

**Inputs:**
- **WACC:** ___% (Risk-free: ___%, Beta: ___, ERP: ___%)
- **Terminal Growth Rate:** ___% (Typically 2-3%)

**Projected Free Cash Flows:**
| Year | 1 | 2 | 3 | 4 | 5 | Terminal |
|------|---|---|---|---|---|----------|
| FCF | | | | | | |

**DCF Value:**
- PV of FCFs: \$___
- PV of Terminal Value: \$___
- **Total Enterprise Value: \$___**
- (-) Net Debt: \$___
- **Equity Value: \$___**
- **DCF Value per Share: \$___**

### 5. Valuation Method B: Exit Multiple (Quality Valuation)

**Inputs:**
- **Target Year $projectionYears EPS:** \$___
- **Fair Exit PE Ratio:** ___x (Justify based on historical avg & future growth)

**Calculation:**
- Future Stock Price = Target EPS × Exit PE = \$___
- **Present Value** (Discounted at desired return rate, e.g., 10-15%): **\$___**

---

## Part 3: Conclusion

**Intrinsic Value Range:** \$___ (Conservative) to \$___ (Optimistic)
**Current Price:** \$___
**Margin of Safety:** ___%

**Verdict:**
- [ ] Undervalued (Buy)
- [ ] Fairly Valued (Hold)
- [ ] Overvalued (Sell)

**Investment Thesis Summary:**
(1-2 sentences on why this is/is not a good investment at the current price, considering both quality and valuation.)

---

Please use `get_company_info` and `get_financial_statements` to retrieve the historical data ($historyYears years) required for this analysis.
''',
          ),
        ),
      ],
    );
  }
}
