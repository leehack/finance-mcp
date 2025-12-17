/// Prompt for generating a comprehensive company analysis.
library;

import 'package:mcp_dart/mcp_dart.dart';

import 'base_prompt.dart';

/// Generates a structured prompt for analyzing a company's financial health.
///
/// This prompt guides the LLM to perform a thorough analysis including:
/// - Business overview and competitive position
/// - Financial metrics analysis (profitability, efficiency, leverage)
/// - Growth trends and sustainability
/// - Risk factors and concerns
/// - Overall investment assessment
class AnalyzeCompanyPrompt extends BasePrompt {
  @override
  String get name => 'analyze_company';

  @override
  String get title => 'Analyze Company';

  @override
  String get description =>
      'Generate a comprehensive financial analysis prompt for a specified '
      'company. Provides a structured template covering business overview, '
      'key metrics, growth analysis, risks, and investment assessment.';

  @override
  Map<String, PromptArgumentDefinition>? get argsSchema => {
        'ticker': PromptArgumentDefinition(
          description: 'Stock ticker symbol (e.g., AAPL, MSFT, GOOGL)',
          required: true,
        ),
        'focus_areas': PromptArgumentDefinition(
          description:
              'Comma-separated list of areas to emphasize (e.g., "profitability,growth,debt")',
        ),
      };

  @override
  GetPromptResult getPrompt(Map<String, dynamic>? args) {
    final ticker = (args?['ticker'] as String?)?.toUpperCase() ?? '[TICKER]';
    final focusAreas = args?['focus_areas'] as String?;

    final focusSection = focusAreas != null
        ? '\n\n**Priority Focus Areas:** ${focusAreas.split(',').map((a) => a.trim()).join(', ')}'
        : '';

    return GetPromptResult(
      description: 'Comprehensive financial analysis prompt for $ticker',
      messages: [
        PromptMessage(
          role: PromptMessageRole.user,
          content: TextContent(
            text:
                '''Perform a comprehensive financial analysis of $ticker.$focusSection

## Analysis Framework

### 1. Business Overview
- What does the company do? What are its main products/services?
- What is its competitive moat or advantage?
- Who are the main competitors?

### 2. Financial Health Assessment
Using the available financial data, analyze:

**Profitability Metrics:**
- Gross Margin, Operating Margin, Net Margin
- Return on Equity (ROE) and Return on Invested Capital (ROIC)
- Trends over the past 3-5 years

**Balance Sheet Strength:**
- Debt-to-Equity ratio
- Current ratio and liquidity position
- Asset composition and quality

**Cash Flow Analysis:**
- Operating cash flow trends
- Free cash flow generation
- Capital allocation (CapEx, dividends, buybacks)

### 3. Growth Analysis
- Revenue growth rate (historical and projected)
- Earnings growth sustainability
- Market expansion opportunities

### 4. Valuation Considerations
- Current valuation multiples (P/E, P/S, EV/EBITDA)
- Historical valuation range
- Comparison to industry peers

### 5. Risk Factors
- Key business risks
- Financial risks (leverage, concentration)
- Industry/macro risks

### 6. Investment Assessment
Based on the analysis above, provide:
- Overall financial health rating (Strong/Adequate/Weak)
- Key strengths and concerns
- Suitability for different investor profiles

Please use the get_company_info and get_financial_statements tools to retrieve the necessary data for this analysis.''',
          ),
        ),
      ],
    );
  }
}
