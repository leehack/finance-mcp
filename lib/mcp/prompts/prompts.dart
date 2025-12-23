/// MCP prompts for the finance-mcp server.
///
/// This library provides modular prompt implementations that can be registered
/// with any MCP server, regardless of transport type (stdio, StreamableHTTP).
///
/// Prompts allow LLMs to request structured input templates for common tasks.
library;

import 'base_prompt.dart';
import 'compare_stocks_prompt.dart';
import 'comprehensive_analysis_prompt.dart';

export 'base_prompt.dart';
export 'compare_stocks_prompt.dart';
export 'comprehensive_analysis_prompt.dart';

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
      ComprehensiveAnalysisPrompt(),
      CompareStocksPrompt(),
    ];
