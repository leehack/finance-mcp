/// Prompt for comparing multiple stocks using comprehensive analysis.
library;

import 'package:mcp_dart/mcp_dart.dart';

import 'base_prompt.dart';

/// Generates a structured prompt for comparing multiple stocks using
/// the comprehensive analysis framework.
///
/// This prompt guides the LLM to perform a side-by-side comparison including:
/// - Financial health comparison
/// - Intrinsic value comparison
/// - Business quality & moat comparison
/// - Sentiment comparison
/// - Investment verdict by investor profile
class CompareStocksPrompt extends BasePrompt {
  @override
  String get name => 'compare_stocks';

  @override
  String get title => 'Compare Stocks';

  @override
  String get description =>
      'Generate a comprehensive comparative analysis for multiple stocks. '
      'Compares financial health, intrinsic value, business quality, '
      'sentiment, and provides investment recommendations by investor profile.';

  @override
  Map<String, PromptArgumentDefinition>? get argsSchema => {
        'tickers': PromptArgumentDefinition(
          description:
              'Comma-separated list of ticker symbols to compare (e.g., "AAPL,MSFT,GOOGL")',
          required: true,
        ),
        'investment_style': PromptArgumentDefinition(
          description:
              'Investment style: "value", "growth", "garp", "quality", "income"',
        ),
      };

  @override
  GetPromptResult getPrompt(Map<String, dynamic>? args) {
    final tickersArg = args?['tickers'] as String? ?? 'AAPL,MSFT';
    final tickers = tickersArg
        .split(',')
        .map((t) => t.trim().toUpperCase())
        .where((t) => t.isNotEmpty)
        .toList();
    final style = args?['investment_style'] as String? ?? 'quality';

    final tickerList = tickers.join(', ');
    final tickerCount = tickers.length;

    final styleText = switch (style.toLowerCase()) {
      'value' => 'Value Investing (margin of safety focus)',
      'growth' => 'Growth Investing (revenue/earnings acceleration)',
      'garp' => 'GARP (growth at reasonable price)',
      'income' => 'Income Investing (dividend focus)',
      _ => 'Quality Investing (durable competitive advantages)',
    };

    // Generate table headers
    final tickerHeaders = tickers.join(' | ');
    final tickerDividers = tickers.map((_) => '---').join(' | ');
    final emptyTickerCells = tickers.map((_) => '').join(' | ');

    return GetPromptResult(
      description: 'Comprehensive stock comparison for $tickerList',
      messages: [
        PromptMessage(
          role: PromptMessageRole.user,
          content: TextContent(
            text:
                '''Perform a comprehensive comparative analysis of these $tickerCount stocks: **$tickerList**

**Investment Style:** $styleText

---

# 📊 PART 1: FINANCIAL HEALTH COMPARISON

## 1.1 Profitability Comparison

| Metric | $tickerHeaders |
|--------|$tickerDividers|
| Gross Margin | $emptyTickerCells |
| Operating Margin | $emptyTickerCells |
| Net Margin | $emptyTickerCells |
| ROE | $emptyTickerCells |
| ROIC | $emptyTickerCells |

**Best Profitability:** [Company] - Reason

---

## 1.2 Balance Sheet Comparison

| Metric | $tickerHeaders |
|--------|$tickerDividers|
| Debt/Equity | $emptyTickerCells |
| Debt/EBITDA | $emptyTickerCells |
| Interest Coverage | $emptyTickerCells |
| Current Ratio | $emptyTickerCells |

**Strongest Balance Sheet:** [Company] - Reason

---

## 1.3 Cash Flow Comparison

| Metric | $tickerHeaders |
|--------|$tickerDividers|
| FCF Margin | $emptyTickerCells |
| FCF Yield | $emptyTickerCells |
| FCF / Net Income | $emptyTickerCells |
| Dividend Coverage | $emptyTickerCells |

**Best Cash Generation:** [Company] - Reason

---

## 1.4 Financial Health Scores

| Company | Profitability | Balance Sheet | Cash Flow | **Overall Health** |
|---------|---------------|---------------|-----------|-------------------|
${tickers.map((t) => '| $t | /10 | /10 | /10 | **/10** |').join('\n')}

**Healthiest Company:** [Company] - Reason

---

# 💰 PART 2: VALUATION COMPARISON

## 2.1 Current Valuation Multiples

| Metric | $tickerHeaders |
|--------|$tickerDividers|
| P/E (TTM) | $emptyTickerCells |
| Forward P/E | $emptyTickerCells |
| EV/EBITDA | $emptyTickerCells |
| P/FCF | $emptyTickerCells |
| P/B | $emptyTickerCells |
| PEG Ratio | $emptyTickerCells |

---

## 2.2 Valuation vs History

| Company | Current P/E | 5Y Avg P/E | Premium/Discount |
|---------|-------------|------------|------------------|
${tickers.map((t) => '| $t | | | |').join('\n')}

---

## 2.3 Intrinsic Value Estimates

| Company | Current Price | Fair Value (DCF) | Fair Value (P/E) | Fair Value (Blended) | Margin of Safety |
|---------|---------------|------------------|------------------|----------------------|------------------|
${tickers.map((t) => '| $t | \$[X] | \$[X] | \$[X] | \$[X] | [X]% |').join('\n')}

**Most Undervalued:** [Company] - Reason
**Most Overvalued:** [Company] - Reason

---

# 🏢 PART 3: BUSINESS QUALITY COMPARISON

## 3.1 Business Overview

| Aspect | $tickerHeaders |
|--------|$tickerDividers|
| Core Business | $emptyTickerCells |
| Revenue Model | $emptyTickerCells |
| Market Position | $emptyTickerCells |
| Key Advantage | $emptyTickerCells |

---

## 3.2 Competitive Moat Comparison

| Moat Source | $tickerHeaders |
|-------------|$tickerDividers|
| Network Effects | $emptyTickerCells |
| Switching Costs | $emptyTickerCells |
| Cost Advantages | $emptyTickerCells |
| Intangible Assets | $emptyTickerCells |
| Efficient Scale | $emptyTickerCells |
| **Moat Rating** | $emptyTickerCells |

Rate each: None / Narrow / Wide

**Strongest Moat:** [Company] - Reason

---

## 3.3 Growth Comparison

| Metric | $tickerHeaders |
|--------|$tickerDividers|
| Revenue CAGR (3Y) | $emptyTickerCells |
| EPS CAGR (3Y) | $emptyTickerCells |
| Expected Growth (5Y) | $emptyTickerCells |
| TAM Opportunity | $emptyTickerCells |

**Best Growth Profile:** [Company] - Reason

---

## 3.4 Management Quality

| Factor | $tickerHeaders |
|--------|$tickerDividers|
| Insider Ownership | $emptyTickerCells |
| Capital Allocation | $emptyTickerCells |
| Track Record | $emptyTickerCells |
| **Management Score** | $emptyTickerCells |

Rate each: /10

---

# 📰 PART 4: SENTIMENT COMPARISON

## 4.1 Analyst Consensus

| Metric | $tickerHeaders |
|--------|$tickerDividers|
| Rating | $emptyTickerCells |
| Price Target | $emptyTickerCells |
| Upside/Downside | $emptyTickerCells |

---

## 4.2 Insider Activity (12 Months)

| Activity | $tickerHeaders |
|----------|$tickerDividers|
| Net Buys/Sells | $emptyTickerCells |
| Trend | $emptyTickerCells |

---

## 4.3 SEC Filing Highlights

**Recent 8-K Material Events:**

| Company | 8-K Event Type | Date | Impact |
|---------|----------------|------|--------|
${tickers.map((t) => '| $t | | | 🟢/🟡/🔴 |').join('\n')}

**10-K/10-Q Key Findings:**

| Company | Key Positive | Key Concern | Risk Factor Changes |
|---------|--------------|-------------|---------------------|
${tickers.map((t) => '| $t | | | |').join('\n')}

---

## 4.4 Overall Sentiment

| Company | Analyst | Insider | News | **Overall** |
|---------|---------|---------|------|-------------|
${tickers.map((t) => '| $t | 🟢/🟡/🔴 | 🟢/🟡/🔴 | 🟢/🟡/🔴 | 🟢/🟡/🔴 |').join('\n')}

---

# 📋 PART 5: INVESTMENT VERDICT

## 5.1 Comprehensive Scorecard

| Dimension | Weight | $tickerHeaders |
|-----------|--------|$tickerDividers|
| Financial Health | 25% | $emptyTickerCells |
| Valuation | 25% | $emptyTickerCells |
| Business Quality | 30% | $emptyTickerCells |
| Sentiment | 20% | $emptyTickerCells |
| **TOTAL SCORE** | 100% | $emptyTickerCells |

---

## 5.2 Risk Comparison

| Risk Factor | $tickerHeaders |
|-------------|$tickerDividers|
| Business Risk | $emptyTickerCells |
| Financial Risk | $emptyTickerCells |
| Valuation Risk | $emptyTickerCells |
| Regulatory Risk | $emptyTickerCells |
| **Overall Risk** | $emptyTickerCells |

Rate each: Low / Medium / High

---

## 5.3 Rankings by Category

| Category | Winner | Runner-up | Rationale |
|----------|--------|-----------|-----------|
| Best for Growth | | | |
| Best for Value | | | |
| Best for Quality | | | |
| Best for Income | | | |
| Best for Safety | | | |
| Best Risk-Adjusted | | | |

---

## 5.4 Investor Profile Recommendations

**For Conservative Investors:**
- **Best Pick:** [Company] - [Reason]
- **Allocation:** [X]%

**For Growth-Oriented Investors:**
- **Best Pick:** [Company] - [Reason]
- **Allocation:** [X]%

**For Value Investors:**
- **Best Pick:** [Company] - [Reason]
- **Allocation:** [X]%

**For Income Investors:**
- **Best Pick:** [Company] - [Reason]
- **Allocation:** [X]%

---

## 5.5 Final Verdict Summary

| Company | Verdict | Target Price | 12M Return | Action |
|---------|---------|--------------|------------|--------|
${tickers.map((t) => '| $t | STRONG BUY / BUY / HOLD / SELL / AVOID | \$[X] | [X]% | |').join('\n')}

---

## 5.6 One-Line Summary

${tickers.map((t) => '**$t:** [One sentence investment thesis]').join('\n\n')}

---

---

# ⚠️ CRITICAL DATA REQUIREMENTS

## Data Freshness Mandate

**YOU MUST fetch the latest available data for each stock.** Before performing any analysis:

1. **Current Stock Prices (MANDATORY):** You MUST obtain the current/latest stock price for each ticker ($tickerList).
   - The MCP tools do NOT provide real-time stock prices.
   - **You MUST search the web** for "[TICKER] stock price today" for each stock.
   - Without current prices, valuation comparison is INCOMPLETE.

2. **Market Data (MANDATORY for valuation):** Search the web if not available via MCP:
   - Current P/E ratio, P/B ratio, EV/EBITDA for each stock
   - 52-week high/low
   - Market capitalization
   - Analyst price targets and ratings

## MCP Data Sources

For each company ($tickerList), use these MCP tools:

1. `get_company_info` - `{"ticker": "[TICKER]"}`

2. `get_financial_statements` - `{"ticker": "[TICKER]"}`

3. `get_sec_filings` - Call twice per ticker:
   - 8-K filings: `{"ticker": "[TICKER]", "forms": ["8-K"], "limit": 5, "includeContent": true}`
   - 10-K/10-Q: `{"ticker": "[TICKER]", "forms": ["10-K", "10-Q"], "limit": 2, "includeContent": true}`

## Web Search Fallback (REQUIRED)

If any data is unavailable from MCP tools, **you MUST search the web** for each ticker:
- "[TICKER] current stock price"
- "[TICKER] P/E ratio market cap"
- "[TICKER] analyst ratings price target"

## Missing Data Warnings (MANDATORY)

At the **START** of your analysis, include a data availability section:

### 📊 Data Availability Summary

| Data Category | $tickerHeaders | Notes |
|--------------|$tickerDividers|-------|
| Current Stock Price | | Web Search |
| Financial Statements | | MCP |
| SEC Filings | | MCP |
| Market Multiples | | Web Search |

Mark each cell with ✅ or ❌.

**⚠️ WARNINGS:** [List any critical data that could not be obtained and how it affects the analysis]

## Completion Requirements

1. **DO NOT SKIP any section.** If data is unavailable, explicitly state what's missing and why.
2. **Every valuation table MUST show current stock prices.** If you don't have them, your analysis is incomplete.
3. **Date-stamp your data.** When reporting prices or metrics, include the date/time.
''',
          ),
        ),
      ],
    );
  }
}
