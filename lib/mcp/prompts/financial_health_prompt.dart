/// Prompt for evaluating a company's financial health.
library;

import 'package:mcp_dart/mcp_dart.dart';

import 'base_prompt.dart';

/// Generates a structured prompt for financial health evaluation.
///
/// This prompt guides the LLM to perform a quick but comprehensive
/// health check focusing on:
/// - Profitability metrics (ROE, ROIC, margins)
/// - Balance sheet strength
/// - Cash flow quality
/// - Red flags identification
/// - Overall health score
class FinancialHealthPrompt extends BasePrompt {
  @override
  String get name => 'financial_health_check';

  @override
  String get title => 'Financial Health Check';

  @override
  String get description =>
      'Generate a financial health check prompt for evaluating key metrics. '
      'Provides a quick assessment framework covering profitability, '
      'leverage, liquidity, and cash flow quality with a final health score.';

  @override
  Map<String, PromptArgumentDefinition>? get argsSchema => {
        'ticker': PromptArgumentDefinition(
          description: 'Stock ticker symbol (e.g., AAPL, MSFT, GOOGL)',
          required: true,
        ),
        'industry': PromptArgumentDefinition(
          description:
              'Industry for context-appropriate benchmarks (e.g., "technology", "banking", "retail")',
        ),
      };

  @override
  GetPromptResult getPrompt(Map<String, dynamic>? args) {
    final ticker = (args?['ticker'] as String?)?.toUpperCase() ?? '[TICKER]';
    final industry = args?['industry'] as String?;

    final industryContext = industry != null
        ? '\n**Industry Context:** $industry (apply industry-appropriate benchmarks)'
        : '';

    return GetPromptResult(
      description: 'Financial health check for $ticker',
      messages: [
        PromptMessage(
          role: PromptMessageRole.user,
          content: TextContent(
            text:
                '''Perform a financial health check for $ticker.$industryContext

---

## Financial Health Assessment

### 1. Profitability Health 📊

| Metric | Current | 3Y Avg | Trend | Assessment |
|--------|---------|--------|-------|------------|
| Gross Margin | | | ↑/↓/→ | 🟢/🟡/🔴 |
| Operating Margin | | | ↑/↓/→ | 🟢/🟡/🔴 |
| Net Margin | | | ↑/↓/→ | 🟢/🟡/🔴 |
| ROE | | | ↑/↓/→ | 🟢/🟡/🔴 |
| ROIC | | | ↑/↓/→ | 🟢/🟡/🔴 |

**Profitability Benchmarks:**
- ROE > 15% = Excellent, 10-15% = Good, < 10% = Needs attention
- ROIC > WACC = Value creating
- Stable or improving margins = Healthy

**Profitability Score:** ___/10

---

### 2. Balance Sheet Health 💰

| Metric | Value | Benchmark | Assessment |
|--------|-------|-----------|------------|
| Debt/Equity | | < 1.0 | 🟢/🟡/🔴 |
| Debt/EBITDA | | < 3.0 | 🟢/🟡/🔴 |
| Interest Coverage | | > 5x | 🟢/🟡/🔴 |
| Current Ratio | | > 1.5 | 🟢/🟡/🔴 |
| Quick Ratio | | > 1.0 | 🟢/🟡/🔴 |

**Debt Maturity Profile:**
- Any near-term maturities to watch?
- Access to credit facilities?

**Balance Sheet Score:** ___/10

---

### 3. Cash Flow Health 💵

| Metric | Value | Assessment |
|--------|-------|------------|
| Operating CF / Net Income | | > 1.0 = 🟢 |
| FCF / Net Income | | > 0.8 = 🟢 |
| FCF Yield | | > 5% = 🟢 |
| CapEx / Revenue | | Industry norm |
| Dividend Coverage (FCF) | | > 1.5x = 🟢 |

**Cash Flow Quality Indicators:**
- [ ] Consistent positive operating cash flow
- [ ] FCF > Net Income (earnings quality)
- [ ] Sustainable CapEx levels
- [ ] Adequate dividend coverage (if applicable)

**Cash Flow Score:** ___/10

---

### 4. Red Flags Checklist 🚩

Check for these warning signs:

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
- [ ] Increasing accounts receivable faster than revenue

**Other:**
- [ ] Auditor changes or qualifications
- [ ] Insider selling patterns
- [ ] Declining returns on capital

**Red Flags Found:** [List any identified issues]

---

### 5. Overall Health Score

| Category | Score | Weight | Weighted |
|----------|-------|--------|----------|
| Profitability | /10 | 35% | |
| Balance Sheet | /10 | 30% | |
| Cash Flow | /10 | 35% | |
| **Total** | | 100% | **/10** |

**Health Rating:**
- 8-10: 💪 Excellent - Strong financial position
- 6-7.9: 👍 Good - Solid fundamentals, minor concerns
- 4-5.9: ⚠️ Fair - Some weaknesses to monitor
- < 4: 🚨 Weak - Significant concerns

---

### 6. Summary & Recommendations

**Key Strengths:**
1. 
2. 
3. 

**Areas of Concern:**
1. 
2. 
3. 

**Monitoring Priorities:**
- What metrics should investors watch closely?
- Any upcoming events that could impact financial health?

---

Please use the get_company_info and get_financial_statements tools to retrieve the necessary data for this health check.''',
          ),
        ),
      ],
    );
  }
}
