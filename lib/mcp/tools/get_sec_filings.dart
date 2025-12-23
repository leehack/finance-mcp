import 'package:mcp_dart/mcp_dart.dart';

import '../../data/data.dart';
import '../../data/services/financial_data_service.dart';
import 'base_tool.dart';

/// Tool for retrieving SEC EDGAR filings for sentiment analysis.
///
/// Fetches filings like 8-K (current reports), 10-K (annual), and 10-Q
/// (quarterly) which contain rich text suitable for NLP analysis.
class GetSecFilingsTool extends BaseTool {
  GetSecFilingsTool(this.dataService);

  /// Financial data service for API calls.
  final FinancialDataService dataService;

  @override
  String get name => 'get_sec_filings';

  @override
  String get description =>
      'Retrieves SEC EDGAR filings (8-K, 10-K, 10-Q, etc.) for a company. '
      'Returns filing metadata and optionally full text content for '
      'sentiment analysis.';

  @override
  ToolAnnotations get annotations => ToolAnnotations(
        title: 'Get SEC Filings',
        readOnlyHint: true,
      );

  @override
  ToolInputSchema get inputSchema => JsonSchema.object(
        properties: {
          'ticker': JsonSchema.string(
            description: 'The stock ticker symbol (e.g., AAPL).',
          ),
          'forms': JsonSchema.array(
            description: "Filing types to include (e.g., ['8-K', '10-K']). "
                'If omitted, returns all form types.',
            items: JsonSchema.string(),
          ),
          'limit': JsonSchema.integer(
            description: 'Maximum number of filings to return (default: 10).',
          ),
          'includeContent': JsonSchema.boolean(
            description:
                'If true, fetches the full text content of each filing. '
                'Useful for sentiment analysis but may be slow for many filings.',
          ),
        },
        required: ['ticker'],
      );

  @override
  ToolOutputSchema? get outputSchema => JsonSchema.object(
        properties: {
          'ticker': JsonSchema.string(description: 'Company ticker'),
          'filings': JsonSchema.array(
            description: 'List of SEC filings',
            items: JsonSchema.object(
              properties: {
                'accessionNumber': JsonSchema.string(
                  description: 'Unique SEC filing identifier',
                ),
                'form': JsonSchema.string(
                  description: 'Filing type (8-K, 10-K, 10-Q, etc.)',
                ),
                'filingDate': JsonSchema.string(
                  description: 'Date filed with SEC',
                ),
                'description': JsonSchema.string(
                  description: 'Brief description of the filing',
                ),
                'url': JsonSchema.string(
                  description: 'URL to the filing on SEC EDGAR',
                ),
                'content': JsonSchema.string(
                  description: 'Full text content (if includeContent=true)',
                ),
              },
            ),
          ),
        },
      );

  @override
  Future<CallToolResult> execute(Map<String, dynamic> args) async {
    final ticker = args['ticker'] as String?;
    final formsArg = args['forms'] as List<dynamic>?;
    final limit = args['limit'] as int? ?? 10;
    final includeContent = args['includeContent'] as bool? ?? false;

    if (ticker == null) {
      return CallToolResult(
        content: [TextContent(text: 'Ticker is required.')],
        isError: true,
      );
    }

    try {
      // Convert forms list if provided
      final forms = formsArg?.map((e) => e.toString()).toList();

      // Fetch filings metadata
      final filings = await dataService.getRecentFilings(
        ticker,
        forms: forms,
        limit: limit,
      );

      if (filings.isEmpty) {
        return CallToolResult(
          content: [
            TextContent(
              text: 'No filings found for $ticker'
                  '${forms != null ? ' with forms: ${forms.join(", ")}' : ""}',
            ),
          ],
        );
      }

      // Optionally fetch content for each filing
      if (includeContent) {
        for (final filing in filings) {
          filing.content = await dataService.getFilingContent(filing);
        }
      }

      final result = {
        'ticker': ticker.toUpperCase(),
        'count': filings.length,
        'filings': filings.map((f) => f.toJson()).toList(),
      };

      return CallToolResult.fromStructuredContent(result);
    } catch (e) {
      return CallToolResult(
        content: [TextContent(text: 'Failed to fetch filings: $e')],
        isError: true,
      );
    }
  }
}
