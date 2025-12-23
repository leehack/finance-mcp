/// Comprehensive stock analysis prompt combining all analysis aspects.
library;

import 'package:mcp_dart/mcp_dart.dart';

import 'base_prompt.dart';

/// Generates a comprehensive analysis prompt that covers all aspects of
/// stock analysis in a single structured workflow.
///
/// This prompt combines:
/// 1. Financial Health Check - profitability, balance sheet, cash flow
/// 2. Intrinsic Value Evaluation - DCF, P/E multiple, ROE models
/// 3. Business & Competitive Analysis - moat, management, industry position
/// 4. Sentiment Analysis - SEC filings, market sentiment, news
/// 5. Investment Thesis - final verdict with actionable recommendations
class ComprehensiveAnalysisPrompt extends BasePrompt {
  @override
  String get name => 'comprehensive_analysis';

  @override
  String get title => 'Comprehensive Stock Analysis';

  @override
  String get description =>
      'Generate a complete stock analysis covering financial health, '
      'intrinsic value, business quality, sentiment analysis, and '
      'investment thesis with actionable recommendations.';

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
              'Investment style: "value", "growth", "garp", "quality", "income"',
        ),
        'history_years': PromptArgumentDefinition(
          description: 'Years of historical data to analyze (default: 10)',
        ),
      };

  @override
  GetPromptResult getPrompt(Map<String, dynamic>? args) {
    final ticker = (args?['ticker'] as String?)?.toUpperCase() ?? '[TICKER]';
    final horizon = args?['investment_horizon'] as String? ?? 'medium';
    final style = args?['investment_style'] as String? ?? 'quality';
    final historyYears =
        int.tryParse(args?['history_years']?.toString() ?? '') ?? 10;

    final horizonText = switch (horizon.toLowerCase()) {
      'short' => '< 1 year (tactical/trading)',
      'long' => '3+ years (long-term compounding)',
      _ => '1-3 years (core holding)',
    };

    final styleText = switch (style.toLowerCase()) {
      'value' => 'Value Investing (margin of safety focus)',
      'growth' => 'Growth Investing (revenue/earnings acceleration)',
      'garp' => 'GARP (growth at reasonable price)',
      'income' => 'Income Investing (dividend focus)',
      _ => 'Quality Investing (durable competitive advantages)',
    };

    return GetPromptResult(
      description: 'Comprehensive analysis for $ticker',
      messages: [
        PromptMessage(
          role: PromptMessageRole.user,
          content: TextContent(
            text:
                '''Perform a comprehensive investment analysis for **$ticker**.

**Analysis Parameters:**
- Time Horizon: $horizonText
- Investment Style: $styleText
- Historical Analysis: Past $historyYears years

---

# 📊 PART 1: FINANCIAL HEALTH CHECK

Evaluate the company's financial health across three dimensions.

## 1.1 Profitability Health

| Metric | Current | $historyYears-Year Avg | Trend | Assessment |
|--------|---------|-----------------|-------|------------|
| Gross Margin | | | ↑/↓/→ | 🟢/🟡/🔴 |
| Operating Margin | | | ↑/↓/→ | 🟢/🟡/🔴 |
| Net Margin | | | ↑/↓/→ | 🟢/🟡/🔴 |
| ROE | | | ↑/↓/→ | 🟢/🟡/🔴 |
| ROIC | | | ↑/↓/→ | 🟢/🟡/🔴 |

**Benchmarks:** ROE > 15% = Excellent | ROIC > WACC = Value Creating

**Profitability Score:** [X]/10

---

## 1.2 Balance Sheet Health

| Metric | Value | Benchmark | Assessment |
|--------|-------|-----------|------------|
| Debt/Equity | | < 1.0 | 🟢/🟡/🔴 |
| Debt/EBITDA | | < 3.0 | 🟢/🟡/🔴 |
| Interest Coverage | | > 5x | 🟢/🟡/🔴 |
| Current Ratio | | > 1.5 | 🟢/🟡/🔴 |
| Quick Ratio | | > 1.0 | 🟢/🟡/🔴 |

**Debt Maturity Profile:** Any near-term maturities? Credit facility access?

**Balance Sheet Score:** [X]/10

---

## 1.3 Cash Flow Health

| Metric | Value | Assessment |
|--------|-------|------------|
| Operating CF / Net Income | | > 1.0 = 🟢 |
| FCF / Net Income | | > 0.8 = 🟢 |
| FCF Yield | | > 5% = 🟢 |
| CapEx / Revenue | | Industry norm |
| Dividend Coverage (FCF) | | > 1.5x = 🟢 |

**Cash Flow Quality Checklist:**
- [ ] Consistent positive operating cash flow
- [ ] FCF > Net Income (earnings quality)
- [ ] Sustainable CapEx levels
- [ ] Adequate dividend coverage

**Cash Flow Score:** [X]/10

---

## 1.4 Red Flags Checklist 🚩

**Earnings Quality:**
- [ ] Large gap between earnings and cash flow
- [ ] Frequent one-time adjustments
- [ ] Aggressive revenue recognition

**Balance Sheet:**
- [ ] Rapidly increasing debt
- [ ] Goodwill > 30% of assets
- [ ] Related party transactions

**Cash Flow:**
- [ ] Negative operating cash flow
- [ ] CapEx cuts to maintain FCF
- [ ] Receivables growing faster than revenue

**Red Flags Found:** [List any identified]

---

## 1.5 Overall Financial Health Score

| Category | Score | Weight | Weighted |
|----------|-------|--------|----------|
| Profitability | /10 | 35% | |
| Balance Sheet | /10 | 30% | |
| Cash Flow | /10 | 35% | |
| **Total** | | 100% | **/10** |

**Health Rating:** 8-10: 💪 Excellent | 6-7.9: 👍 Good | 4-5.9: ⚠️ Fair | < 4: 🚨 Weak

---

# 💰 PART 2: INTRINSIC VALUE EVALUATION

Estimate fair value using multiple valuation methods.

## 2.1 Historical Valuation Context

| Metric | Current | 5Y Low | 5Y High | 5Y Avg |
|--------|---------|--------|---------|--------|
| P/E Ratio | | | | |
| EV/EBITDA | | | | |
| P/FCF | | | | |
| P/B | | | | |

**Industry Comparison:**
| Metric | $ticker | Peer 1 | Peer 2 | Industry Avg |
|--------|---------|--------|--------|--------------|
| P/E | | | | |
| EV/EBITDA | | | | |

---

## 2.2 Method A: Discounted Cash Flow (DCF)

**Key Assumptions:**
- WACC: [X]% (Risk-free: [X]%, Beta: [X], ERP: [X]%)
- Terminal Growth Rate: [X]% (typically 2-3%)
- FCF Growth (Years 1-5): [X]%

| Year | 1 | 2 | 3 | 4 | 5 | Terminal |
|------|---|---|---|---|---|----------|
| FCF (Millions) | | | | | | |

**DCF Calculation:**
- PV of FCFs: \$[X]
- PV of Terminal Value: \$[X]
- Enterprise Value: \$[X]
- (-) Net Debt: \$[X]
- Equity Value: \$[X]
- **DCF Value per Share: \$[X]**

---

## 2.3 Method B: P/E Multiple Model

**Inputs:**
- Current EPS: \$[X]
- Expected EPS CAGR (5Y): [X]%
- Target P/E (conservative): [X]

**Calculation:**
- Future EPS (Year 5): \$[X]
- Future Price: Future EPS × Target P/E = \$[X]
- **Present Value (discounted): \$[X]**

---

## 2.4 Method C: ROE & Book Value Model

**Inputs:**
- Current Book Value per Share: \$[X]
- Average ROE: [X]%
- Retention Ratio: [X]
- Sustainable Growth: ROE × Retention = [X]%

**Calculation:**
- Future BVPS (Year 5): \$[X]
- Future Price (at historical P/B): \$[X]
- **Present Value (discounted): \$[X]**

---

## 2.5 Valuation Summary

| Method | Fair Value | Current Price | Margin of Safety |
|--------|------------|---------------|------------------|
| DCF | \$[X] | \$[X] | [X]% |
| P/E Multiple | \$[X] | \$[X] | [X]% |
| ROE/Book Value | \$[X] | \$[X] | [X]% |
| **Weighted Average** | \$[X] | \$[X] | **[X]%** |

---

# 🏢 PART 3: BUSINESS & COMPETITIVE ANALYSIS

Assess the quality and durability of the business.

## 3.1 Business Overview

**Core Business:**
- What does the company do?
- Main products/services and revenue breakdown
- Geographic revenue mix
- Customer concentration

---

## 3.2 Competitive Moat Analysis

Evaluate each moat source (Strong/Moderate/Weak/None):

| Moat Source | Present? | Durability | Evidence |
|-------------|----------|------------|----------|
| Network Effects | | | |
| Switching Costs | | | |
| Cost Advantages | | | |
| Intangible Assets (Brand/IP) | | | |
| Efficient Scale | | | |

**Overall Moat Rating:** ⬛⬛⬛⬛⬛ (None/Narrow/Wide)

---

## 3.3 Industry & Competitive Position

**Industry Analysis:**
- Industry growth trends
- Competitive landscape
- Regulatory environment
- Technology disruption risk

**Competitive Positioning:**
- Market share and trends
- Key competitors and differentiation
- Barriers to entry

---

## 3.4 Management Quality

**Capital Allocation Track Record:**
- Historical ROIC trends
- M&A track record
- Dividend/buyback discipline
- Insider ownership

**Management Score:** [X]/10

---

# 📰 PART 4: SENTIMENT ANALYSIS

Assess market and regulatory sentiment.

## 4.1 SEC Filing Analysis

**8-K Material Events (Last 90 Days):**
Review recent 8-K filings for material events:

| Item | Type | Description | Sentiment |
|------|------|-------------|----------|
| 1.01 | Entry into Material Agreement | | 🟢/🟡/🔴 |
| 1.02 | Termination of Agreement | | 🟢/🟡/🔴 |
| 2.01 | Acquisition/Disposition | | 🟢/🟡/🔴 |
| 2.02 | Results of Operations | | 🟢/🟡/🔴 |
| 5.02 | Executive Changes | | 🟢/🟡/🔴 |
| 7.01 | Regulation FD Disclosure | | 🟢/🟡/🔴 |
| 8.01 | Other Events | | 🟢/🟡/🔴 |

**10-K/10-Q Key Takeaways:**
- Management Discussion & Analysis highlights
- Risk factors (new or changed)
- Legal proceedings status
- Related party transactions

**Auditor Opinion:** Clean / Qualified / Adverse

---

## 4.2 Insider Activity

| Period | Buys | Sells | Net Activity |
|--------|------|-------|--------------|
| 3 Months | | | |
| 12 Months | | | |

**Notable Insider Transactions:** [List significant transactions]

---

## 4.3 Analyst Sentiment

| Rating | Count | Price Target Range |
|--------|-------|-------------------|
| Strong Buy | | |
| Buy | | |
| Hold | | |
| Sell | | |

**Consensus Price Target:** \$[X]
**Current vs Target:** [X]% upside/downside

---

## 4.4 Management Tone Analysis

Analyze language patterns from recent earnings calls and 8-K filings:

| Indicator | Current | Prior Period | Trend |
|-----------|---------|--------------|-------|
| Hedging Words (may, could, uncertain) | Low/Med/High | | ↑/↓/→ |
| Confidence Words (will, confident, strong) | Low/Med/High | | ↑/↓/→ |
| Forward Guidance Specificity | Vague/Moderate/Specific | | |
| Tone Shift vs Prior Period | Positive/Neutral/Negative | | |

**Key Quotes:** [Extract 1-2 notable management statements]

---

## 4.5 News & Social Sentiment

**Recent News Themes:**
- Positive catalysts:
- Negative concerns:
- Neutral developments:

**Overall Sentiment Score:** Bullish / Neutral / Bearish

---

# 📋 PART 5: INVESTMENT THESIS

Final synthesis and actionable recommendations.

## 5.1 Executive Summary

Write 2-3 sentences capturing:
- Why this is/isn't a compelling investment
- Primary driver of expected returns
- Key risk or advantage

---

## 5.2 Scorecard Summary

| Dimension | Score | Weight | Weighted |
|-----------|-------|--------|----------|
| Financial Health | /10 | 25% | |
| Valuation | /10 | 25% | |
| Business Quality | /10 | 30% | |
| Sentiment | /10 | 20% | |
| **Total Score** | | 100% | **/10** |

---

## 5.3 Key Investment Drivers

**Bull Case (Why It Could Outperform):**
1. 
2. 
3. 

**Bear Case (Why It Could Underperform):**
1. 
2. 
3. 

---

## 5.4 Risk Assessment

| Risk | Probability | Impact | Mitigant |
|------|-------------|--------|----------|
| | H/M/L | H/M/L | |
| | H/M/L | H/M/L | |
| | H/M/L | H/M/L | |

**Thesis Killers (Would Invalidate Investment):**
1. 
2. 
3. 

---

## 5.5 Action Plan & Position Management

**Verdict:** 
- [ ] **STRONG BUY** - Exceptional opportunity, high conviction
- [ ] **BUY** - Attractive risk/reward
- [ ] **HOLD** - Fairly valued, maintain position
- [ ] **SELL** - Deteriorating fundamentals or overvalued
- [ ] **AVOID** - Significant concerns

**Entry Strategy:**
- Target Entry Price: \$[X] ([X]% below current)
- Scale-in approach: [Full / 3 tranches / Dollar-cost average]

**Position Sizing:**
- Recommended Allocation: [X]% of portfolio
- Rationale: [Based on conviction, volatility, correlation]

**Exit Criteria:**
- Price Target (12-month): \$[X] ([X]% upside)
- Stop Loss: \$[X] ([X]% downside)
- Thesis Review Triggers:
  - [ ] Quarterly earnings miss > 10%
  - [ ] Dividend cut
  - [ ] Management departure
  - [ ] Competitive threat emergence

---

## 5.6 Expected Returns Profile

**Base Case Scenario:**
- Probability: [X]%
- 5-Year Price Target: \$[X]
- Annual Return (CAGR): [X]%

**Bull Case Scenario:**
- Probability: [X]%
- 5-Year Price Target: \$[X]
- Annual Return (CAGR): [X]%

**Bear Case Scenario:**
- Probability: [X]%
- 5-Year Price Target: \$[X]
- Annual Return (CAGR): [X]%

**Weighted Expected Return (CAGR):** [X]%

---

## 5.7 One-Page Investment Summary

| Metric | Value |
|--------|-------|
| **Ticker** | $ticker |
| **Current Price** | \$[X] |
| **Fair Value Estimate** | \$[X] |
| **Margin of Safety** | [X]% |
| **Financial Health** | /10 |
| **Business Quality** | /10 |
| **Overall Score** | /10 |
| **Verdict** | BUY / HOLD / SELL |
| **Target Allocation** | [X]% |
| **12-Month Target** | \$[X] |

---

---

# ⚠️ CRITICAL DATA REQUIREMENTS

## Data Freshness Mandate

**YOU MUST fetch the latest available data.** Before performing any analysis:

1. **Current Stock Price (MANDATORY):** You MUST obtain the current/latest stock price for $ticker.
   - The MCP tools do NOT provide real-time stock prices.
   - **You MUST search the web** for "$ticker stock price today" to get the current price.
   - Without current price, valuation analysis is INCOMPLETE.

2. **Market Data (MANDATORY for valuation):** Search the web if not available via MCP:
   - Current P/E ratio, P/B ratio, EV/EBITDA
   - 52-week high/low
   - Market capitalization
   - Beta coefficient
   - Analyst price targets and ratings

## MCP Data Sources

Use the following MCP tools with these specific parameters:

1. `get_company_info` - Company overview and profile
   - Parameters: `{"ticker": "$ticker"}`

2. `get_financial_statements` - Historical financials (income, balance sheet, cash flow)
   - Parameters: `{"ticker": "$ticker", "years": $historyYears}`

3. `get_sec_filings` - SEC filings for sentiment analysis
   - **For 8-K events:** `{"ticker": "$ticker", "forms": ["8-K"], "limit": 10, "includeContent": true}`
   - **For annual/quarterly:** `{"ticker": "$ticker", "forms": ["10-K", "10-Q"], "limit": 4, "includeContent": true}`

## Web Search Fallback (REQUIRED)

If any data is unavailable from MCP tools, **you MUST search the web** for:
- "$ticker current stock price"
- "$ticker P/E ratio market cap"
- "$ticker analyst ratings price target"
- "$ticker latest news"
- "$ticker investor relations"

## Missing Data Warnings (MANDATORY)

At the **START** of your analysis, you MUST include a data availability section:

### 📊 Data Availability Summary

| Data Category | Source | Status | Notes |
|--------------|--------|--------|-------|
| Current Stock Price | Web Search | ✅/❌ | |
| Financial Statements | MCP | ✅/❌ | |
| SEC Filings | MCP | ✅/❌ | |
| Market Multiples (P/E, EV/EBITDA) | Web Search | ✅/❌ | |
| Analyst Estimates | Web Search | ✅/❌ | |

**⚠️ WARNINGS:** [List any critical data that could not be obtained and how it affects the analysis]

## Completion Requirements

1. **DO NOT SKIP any section.** If data is unavailable, explicitly state:
   - What data is missing
   - Why it could not be obtained
   - How this limitation affects the analysis
   - Any reasonable estimates or alternatives used

2. **Every valuation method MUST show the current stock price.** If you don't have it, your analysis is incomplete.

3. **Date-stamp your data.** When reporting prices or metrics, include the date/time of the data.
''',
          ),
        ),
      ],
    );
  }
}
