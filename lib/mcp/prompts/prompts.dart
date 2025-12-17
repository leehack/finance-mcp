/// MCP prompts for the finance-mcp server.
///
/// This library provides modular prompt implementations that can be registered
/// with any MCP server, regardless of transport type (stdio, StreamableHTTP).
///
/// Prompts allow LLMs to request structured input templates for common tasks.
library;

import 'analyze_company_prompt.dart';
import 'base_prompt.dart';
import 'compare_stocks_prompt.dart';
import 'dcf_valuation_prompt.dart';
import 'financial_health_prompt.dart';
import 'investment_thesis_prompt.dart';

export 'analyze_company_prompt.dart';
export 'base_prompt.dart';
export 'compare_stocks_prompt.dart';
export 'dcf_valuation_prompt.dart';
export 'financial_health_prompt.dart';
export 'investment_thesis_prompt.dart';

/// Creates all available prompts.
///
/// Use this to register all prompts with an MCP server:
/// ```dart
/// final prompts = createAllPrompts();
/// for (final prompt in prompts) {
///   server.registerBasePrompt(prompt);
/// }
/// ```
List<BasePrompt> createAllPrompts() => [
      AnalyzeCompanyPrompt(),
      CompareStocksPrompt(),
      InvestmentThesisPrompt(),
      DcfValuationPrompt(),
      FinancialHealthPrompt(),
    ];
