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
**Logic Check:** Sustained high growth requires high ROE.
- **Retention Ratio:** (1 - Payout Ratio)
- **Sustainable Growth Rate:** ROE × Retention Ratio = ___%

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

### 5. Valuation Method B: P/E Multiple Model (Historical Pricing)

This method projects value based on Earnings Per Share (EPS) growth and historical Price-to-Earnings ratios.

**Inputs:**
- **Current EPS:** \$___
- **Expected EPS Growth Rate:** ___%
- **Target P/E Ratio:** ___ (Historical Average or Conservative estimate)

**Calculation:**
- **Future EPS (Year $projectionYears):** Current EPS × (1 + Growth Rate)^$projectionYears = \$___
- **Future Stock Price:** Future EPS × Target P/E = **\$___**
- **Fair Value (Discounted):** Future Price / (1 + Discount Rate)^$projectionYears = **\$___**

### 6. Valuation Method C: ROE & Book Value Model (Quality Valuation)

This method projects value based on Equity growth (Book Value) driven by ROE.

**Inputs:**
- **Current Book Value per Share (BVPS):** \$___
- **Average ROE (5-10yr):** ___%
- **Retention Ratio:** (1 - Payout Ratio) = ___%
- **Sustainable Growth Rate:** ROE × Retention Ratio = **___%**
- **Target P/B Ratio:** ___ (Historical Average)

**Calculation:**
- **Future BVPS (Year $projectionYears):** Current BVPS × (1 + Sustainable Growth Rate)^$projectionYears = \$___
- **Future Stock Price:** Future BVPS × Target P/B = **\$___**
- **Fair Value (Discounted):** Future Price / (1 + Discount Rate)^$projectionYears = **\$___**

---

## Part 3: Conclusion

| Valuation Method | Value per Share (Buy Price) | Current Price | Margin of Safety |
|------------------|-----------------------------|---------------|------------------|
| **DCF** | \$___ | \$___ | ___% |
| **PE Multiple** | \$___ | \$___ | ___% |
| **ROE & Book Value** | \$___ | \$___ | ___% |

### Returns Profile (5-Year Horizon)
Based on the average of the models above:
- **Current Price:** \$___
- **Projected Future Price (Year $projectionYears):** \$___ (Avg of models)
- **Implied 5-Year Upside:** ___%
- **Implied Annual Return (CAGR):** ___% 
*(Note: Compare this CAGR to your required rate of return. If it's >15%, the stock is likely a strong buy.)*

**Verdict:**
- [ ] Undervalued (Buy) - >50% Margin of Safety preferred
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
