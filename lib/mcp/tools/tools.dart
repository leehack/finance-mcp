/// MCP tools for the finance-mcp server.
///
/// This library provides modular tool implementations that can be registered
/// with any MCP server, regardless of transport type (stdio, StreamableHTTP).
library;

import '../../data/services/financial_data_service.dart';
import 'base_tool.dart';
import 'get_company_info.dart';
import 'get_financial_statements.dart';
import 'get_sec_filings.dart';

export 'base_tool.dart';
export 'get_company_info.dart';
export 'get_financial_statements.dart';
export 'get_sec_filings.dart';

/// Creates all available tools with the provided [FinancialDataService].
///
/// Use this to register all tools with an MCP server:
/// ```dart
/// final tools = createAllTools(dataService);
/// for (final tool in tools) {
///   server.registerBaseTool(tool);
/// }
/// ```
List<BaseTool> createAllTools(FinancialDataService dataService) => [
      GetCompanyInfoTool(dataService),
      GetFinancialStatementsTool(dataService),
      GetSecFilingsTool(dataService),
    ];
