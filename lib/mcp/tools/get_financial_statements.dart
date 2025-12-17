import 'package:mcp_dart/mcp_dart.dart';

import '../../data/models/financial_statements.dart';
import '../../data/services/financial_data_service.dart';
import 'base_tool.dart';

/// Tool for retrieving comprehensive financial statements with computed metrics.
class GetFinancialStatementsTool extends BaseTool {
  GetFinancialStatementsTool(this.dataService);

  /// Financial data service for API calls.
  final FinancialDataService dataService;

  @override
  String get name => 'get_financial_statements';

  @override
  String get description =>
      'Retrieves comprehensive financial statements with computed metrics '
      '(ROE, ROIC, margins, etc.) for a company. Returns multiple periods '
      'when year is not specified.';

  @override
  ToolInputSchema get inputSchema => JsonSchema.object(
        properties: {
          'ticker': JsonSchema.string(
            description: 'The stock ticker symbol.',
          ),
          'period': JsonSchema.string(
            enumValues: ['annual', 'quarterly'],
            description:
                "The reporting period type. 'annual' for FY, 'quarterly' "
                'for Q1-Q4. Defaults to annual.',
          ),
          'year': JsonSchema.integer(
            description:
                'Specific fiscal year to retrieve (e.g., 2023). If omitted, '
                'returns all available periods up to `years` years.',
          ),
          'years': JsonSchema.integer(
            description:
                'Number of years of historical data to fetch (default: 5).',
          ),
        },
        required: ['ticker'],
      );

  @override
  ToolOutputSchema? get outputSchema => JsonSchema.object(
        properties: {
          'ticker': JsonSchema.string(description: 'Company ticker'),
          'companyName': JsonSchema.string(description: 'Company name'),
          'periodType': JsonSchema.string(description: 'annual or quarterly'),
          'statements': JsonSchema.array(
            description: 'Array of financial statements for each period',
            items: JsonSchema.object(
              properties: {
                'fiscalPeriod': JsonSchema.string(
                  description: 'Period identifier (e.g., 2024-FY, 2024-Q3)',
                ),
                'incomeStatement': JsonSchema.object(
                  description: 'Income statement data with margins',
                ),
                'balanceSheet': JsonSchema.object(
                  description: 'Balance sheet data with ratios',
                ),
                'cashFlowStatement': JsonSchema.object(
                  description: 'Cash flow data with free cash flow',
                ),
                'returnOnEquity': JsonSchema.number(
                  description: 'ROE = Net Income / Equity',
                ),
                'returnOnCapital': JsonSchema.number(
                  description: 'ROC = (Net Income - Dividends) / '
                      '(Equity + Non-Current Liabilities)',
                ),
                'roic': JsonSchema.number(
                  description: 'Return on Invested Capital',
                ),
              },
            ),
          ),
        },
      );

  @override
  Future<CallToolResult> execute(Map<String, dynamic> args) async {
    final ticker = args['ticker'] as String?;
    final periodInput = args['period'] as String? ?? 'annual';
    final year = args['year'] as int?;
    final years = args['years'] as int? ?? 5;

    if (ticker == null) {
      return CallToolResult(
        content: [TextContent(text: 'Ticker is required.')],
        isError: true,
      );
    }

    try {
      // Fetch comprehensive financial data
      final financials = await dataService.getHistoricalFinancials(
        ticker,
        years: years,
        includeQuarterly: periodInput == 'quarterly',
      );

      // Get matching statements
      List<FinancialStatements> statements;

      if (periodInput == 'annual') {
        statements = financials.annualStatements;
      } else {
        statements = financials.statements.values
            .where((s) => s.fiscalPeriod.isQuarterly)
            .toList()
          ..sort((a, b) {
            final yearCmp = b.fiscalPeriod.year.compareTo(a.fiscalPeriod.year);
            if (yearCmp != 0) return yearCmp;
            return b.fiscalPeriod.period.compareTo(a.fiscalPeriod.period);
          });
      }

      // Filter by specific year if provided
      if (year != null) {
        statements =
            statements.where((s) => s.fiscalPeriod.year == year).toList();
      }

      if (statements.isEmpty) {
        return CallToolResult(
          content: [
            TextContent(
              text: 'No data found for $ticker '
                  '(year: ${year ?? "all"}, period: $periodInput)',
            ),
          ],
          isError: true,
        );
      }

      // Build rich response with all periods
      final result = {
        'ticker': ticker.toUpperCase(),
        'companyName': financials.companyName,
        'periodType': periodInput,
        'yearsRequested': years,
        'statements': statements.map((s) => s.toJson()).toList(),
      };

      return CallToolResult.fromStructuredContent(result);
    } catch (e) {
      return CallToolResult(
        content: [TextContent(text: 'Failed to fetch financials: $e')],
        isError: true,
      );
    }
  }
}
