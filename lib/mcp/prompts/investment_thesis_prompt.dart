/// Prompt for building a structured investment thesis.
library;

import 'package:mcp_dart/mcp_dart.dart';

import 'base_prompt.dart';

/// Generates a structured prompt for building an investment thesis.
///
/// This prompt guides the LLM to construct a complete investment thesis:
/// - Executive summary and key thesis statement
/// - Business quality assessment
/// - Valuation analysis
/// - Catalyst identification
/// - Risk analysis and mitigants
/// - Position sizing and entry/exit criteria
class InvestmentThesisPrompt extends BasePrompt {
  @override
  String get name => 'investment_thesis';

  @override
  String get title => 'Build Investment Thesis';

  @override
  String get description =>
      'Generate a structured investment thesis prompt for a stock. '
      'Creates a comprehensive framework for documenting the bull case, '
      'key catalysts, risks, and position management criteria.';

  @override
  Map<String, PromptArgumentDefinition>? get argsSchema => {
        'ticker': PromptArgumentDefinition(
          description: 'Stock ticker symbol (e.g., AAPL, MSFT, GOOGL)',
          required: true,
        ),
        'investment_horizon': PromptArgumentDefinition(
          description:
              'Investment time horizon: "short" (< 1 year), "medium" (1-3 years), "long" (3+ years)',
        ),
        'investment_style': PromptArgumentDefinition(
          description:
              'Investment style: "value", "growth", "garp" (growth at reasonable price), "quality"',
        ),
      };

  @override
  GetPromptResult getPrompt(Map<String, dynamic>? args) {
    final ticker = (args?['ticker'] as String?)?.toUpperCase() ?? '[TICKER]';
    final horizon = args?['investment_horizon'] as String? ?? 'medium';
    final style = args?['investment_style'] as String? ?? 'quality';

    final horizonText = switch (horizon.toLowerCase()) {
      'short' => '< 1 year (tactical/trading)',
      'long' => '3+ years (long-term compounding)',
      _ => '1-3 years (core holding)',
    };

    final styleText = switch (style.toLowerCase()) {
      'value' => 'Value Investing (margin of safety focus)',
      'growth' => 'Growth Investing (revenue/earnings acceleration)',
      'garp' => 'GARP (growth at reasonable price)',
      _ => 'Quality Investing (durable competitive advantages)',
    };

    return GetPromptResult(
      description: 'Investment thesis framework for $ticker',
      messages: [
        PromptMessage(
          role: PromptMessageRole.user,
          content: TextContent(
            text: '''Build a comprehensive investment thesis for $ticker.

**Investment Parameters:**
- Time Horizon: $horizonText
- Investment Style: $styleText

---

## Investment Thesis Template

### 1. Executive Summary
Write a 2-3 sentence thesis statement that captures:
- Why this is a compelling investment
- The primary driver of expected returns
- The margin of safety or key advantage

### 2. Business Quality Assessment

**Competitive Moat Analysis:**
- [ ] Network effects
- [ ] Switching costs
- [ ] Cost advantages
- [ ] Intangible assets (brands, patents)
- [ ] Efficient scale

Rate moat durability: Strong / Moderate / Weak

**Business Model Quality:**
- Revenue model (recurring vs. transactional)
- Customer concentration risk
- Pricing power evidence
- Capital intensity

### 3. Financial Strength

**Key Metrics to Analyze:**
- Profitability: ROE, ROIC, margins (vs. cost of capital)
- Growth: Revenue and earnings CAGR (3Y, 5Y)
- Balance Sheet: Debt/Equity, Interest Coverage
- Cash Flow: FCF yield, FCF conversion rate

**Financial Quality Score:** ___/10

### 4. Valuation Analysis

**Current Valuation:**
- P/E (trailing and forward)
- EV/EBITDA
- P/FCF
- Comparison to 5-year historical range
- Comparison to peers

**Intrinsic Value Estimate:**
- Method used (DCF, comparable, sum-of-parts)
- Key assumptions
- Fair value range: \$___ to \$___
- Margin of safety at current price: ___%

### 5. Catalyst Identification

**Near-term Catalysts (0-12 months):**
1. 
2. 
3. 

**Long-term Catalysts (1-3+ years):**
1. 
2. 
3. 

### 6. Risk Analysis

**Key Risks:**
| Risk | Probability | Impact | Mitigant |
|------|-------------|--------|----------|
| | | | |
| | | | |
| | | | |

**Kill Criteria (what would invalidate the thesis):**
1. 
2. 
3. 

### 7. Position Management

**Entry Strategy:**
- Target entry price: \$___
- Scaling approach: Full position / Scale in

**Position Sizing:**
- Recommended allocation: ___% of portfolio
- Rationale: (conviction level, risk/reward)

**Exit Criteria:**
- Price target: \$___ (___% upside)
- Stop loss: \$___ (___% downside)
- Thesis review triggers

---

Please use the get_company_info and get_financial_statements tools to gather the necessary financial data to complete this investment thesis.''',
          ),
        ),
      ],
    );
  }
}
