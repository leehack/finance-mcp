import 'dart:convert';

import 'package:mcp_dart/mcp_dart.dart';

import '../../data/services/financial_data_service.dart';
import 'base_tool.dart';

/// Tool for retrieving basic company metadata and CIK number.
class GetCompanyInfoTool extends BaseTool {
  GetCompanyInfoTool(this.dataService);

  /// Financial data service for API calls.
  final FinancialDataService dataService;

  @override
  String get name => 'get_company_info';

  @override
  String get description =>
      'Retrieves basic company metadata and CIK number from a ticker symbol.';

  @override
  ToolInputSchema get inputSchema => JsonSchema.object(
        properties: {
          'ticker': JsonSchema.string(
            description: 'The stock ticker symbol (e.g., AAPL, MSFT).',
          ),
        },
        required: ['ticker'],
      );

  @override
  ToolOutputSchema? get outputSchema => JsonSchema.object(
        properties: {
          'ticker': JsonSchema.string(
            description: 'Uppercase ticker symbol',
          ),
          'cik': JsonSchema.integer(
            description: 'SEC CIK number',
          ),
          'cik_formatted': JsonSchema.string(
            description: '10-digit zero-padded CIK',
          ),
        },
      );

  @override
  Future<CallToolResult> execute(Map<String, dynamic> args) async {
    final ticker = args['ticker'] as String?;
    if (ticker == null || ticker.isEmpty) {
      return CallToolResult(
        content: [TextContent(text: 'Ticker is required.')],
        isError: true,
      );
    }

    try {
      final cik = await dataService.getCik(ticker);
      if (cik == null) {
        return CallToolResult(
          content: [TextContent(text: "Ticker '$ticker' not found.")],
          isError: true,
        );
      }
      final result = {
        'ticker': ticker.toUpperCase(),
        'cik': cik,
        'cik_formatted': cik.toString().padLeft(10, '0'),
      };
      return CallToolResult(
        content: [TextContent(text: jsonEncode(result))],
      );
    } catch (e) {
      return CallToolResult(
        content: [TextContent(text: 'Failed to fetch company info: $e')],
        isError: true,
      );
    }
  }
}
