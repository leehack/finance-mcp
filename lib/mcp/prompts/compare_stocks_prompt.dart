/// Prompt for comparing multiple stocks/companies.
library;

import 'package:mcp_dart/mcp_dart.dart';

import 'base_prompt.dart';

/// Generates a structured prompt for comparing multiple stocks.
///
/// This prompt guides the LLM to perform a side-by-side comparison including:
/// - Business model comparison
/// - Financial metrics comparison table
/// - Competitive positioning
/// - Risk/reward assessment for each
/// - Recommendation based on investor profile
class CompareStocksPrompt extends BasePrompt {
  @override
  String get name => 'compare_stocks';

  @override
  String get title => 'Compare Stocks';

  @override
  String get description =>
      'Generate a comparative analysis prompt for multiple stocks. '
      'Creates a structured framework for side-by-side comparison of '
      'financial metrics, competitive positioning, and investment merit.';

  @override
  Map<String, PromptArgumentDefinition>? get argsSchema => {
        'tickers': PromptArgumentDefinition(
          description:
              'Comma-separated list of ticker symbols to compare (e.g., "AAPL,MSFT,GOOGL")',
          required: true,
        ),
        'comparison_type': PromptArgumentDefinition(
          description:
              'Type of comparison: "quick" for key metrics only, "detailed" for full analysis',
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
    final comparisonType = args?['comparison_type'] as String? ?? 'detailed';
    final isQuick = comparisonType.toLowerCase() == 'quick';

    final tickerList = tickers.join(', ');
    final tickerCount = tickers.length;

    final detailedSection = isQuick
        ? ''
        : '''

### 3. Detailed Metric Comparison

**Profitability:**
| Metric | ${tickers.join(' | ')} |
|--------|${tickers.map((_) => '---').join('|')}|
| Gross Margin | ${tickers.map((_) => '').join(' | ')} |
| Operating Margin | ${tickers.map((_) => '').join(' | ')} |
| Net Margin | ${tickers.map((_) => '').join(' | ')} |
| ROE | ${tickers.map((_) => '').join(' | ')} |
| ROIC | ${tickers.map((_) => '').join(' | ')} |

**Growth & Efficiency:**
| Metric | ${tickers.join(' | ')} |
|--------|${tickers.map((_) => '---').join('|')}|
| Revenue Growth (3Y) | ${tickers.map((_) => '').join(' | ')} |
| EPS Growth (3Y) | ${tickers.map((_) => '').join(' | ')} |
| Asset Turnover | ${tickers.map((_) => '').join(' | ')} |

**Balance Sheet:**
| Metric | ${tickers.join(' | ')} |
|--------|${tickers.map((_) => '---').join('|')}|
| Debt/Equity | ${tickers.map((_) => '').join(' | ')} |
| Current Ratio | ${tickers.map((_) => '').join(' | ')} |
| Interest Coverage | ${tickers.map((_) => '').join(' | ')} |

### 4. Qualitative Comparison
For each company, assess:
- Competitive moat strength
- Management quality indicators
- Industry position and trends
- Innovation and R&D investment

### 5. Risk Comparison
| Risk Factor | ${tickers.join(' | ')} |
|-------------|${tickers.map((_) => '---').join('|')}|
| Business Risk | ${tickers.map((_) => '').join(' | ')} |
| Financial Risk | ${tickers.map((_) => '').join(' | ')} |
| Valuation Risk | ${tickers.map((_) => '').join(' | ')} |
''';

    return GetPromptResult(
      description: 'Stock comparison prompt for $tickerList',
      messages: [
        PromptMessage(
          role: PromptMessageRole.user,
          content: TextContent(
            text:
                '''Perform a ${isQuick ? 'quick' : 'detailed'} comparative analysis of these $tickerCount stocks: $tickerList

## Comparison Framework

### 1. Company Overview
For each company, briefly describe:
- Core business and revenue sources
- Market position and competitive advantages
- Recent strategic developments

### 2. Key Metrics Summary
| Company | Market Cap | Revenue | Net Income | P/E | Forward P/E |
|---------|------------|---------|------------|-----|-------------|
${tickers.map((t) => '| $t | | | | | |').join('\n')}
$detailedSection
### ${isQuick ? '3' : '6'}. Investment Verdict

**Ranking by Category:**
- Best for Growth: [Company] - Reason
- Best for Value: [Company] - Reason
- Best for Dividend/Income: [Company] - Reason
- Best for Risk-Adjusted Returns: [Company] - Reason

**Overall Recommendation:**
Provide a clear recommendation based on:
- Conservative investor profile
- Growth-oriented investor profile
- Income-focused investor profile

Please use the get_company_info and get_financial_statements tools to retrieve data for each company before completing this comparison.''',
          ),
        ),
      ],
    );
  }
}
