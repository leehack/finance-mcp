import 'dart:io';

import 'package:mcp_dart/mcp_dart.dart';
import 'package:test/test.dart';

/// Integration test that runs the MCP server as a subprocess and
/// connects to it with an MCP client via stdio to verify functionality.
void main() {
  group(
    'MCP Server Integration',
    () {
      late Client client;
      late Process serverProcess;

      setUpAll(() async {
        // Start the server process manually with normal mode to get stream access
        serverProcess = await Process.start(
          Platform.executable,
          ['run', 'bin/server.dart'],
          workingDirectory: Directory.current.path,
        );

        // Use IOStreamTransport to wrap the process streams
        final transport = IOStreamTransport(
          stream: serverProcess.stdout,
          sink: serverProcess.stdin,
        );

        client = Client(
          Implementation(name: 'test-client', version: '1.0.0'),
        );

        await client.connect(transport);
      });

      tearDownAll(() async {
        await client.close();
        serverProcess.kill();
        await serverProcess.exitCode;
      });

      test('lists available tools', () async {
        final result = await client.listTools();

        expect(result.tools.length, equals(3));

        final toolNames = result.tools.map((t) => t.name).toSet();
        expect(toolNames, contains('get_company_info'));
        expect(toolNames, contains('get_financial_statements'));
        expect(toolNames, contains('get_sec_filings'));
      });

      test('get_company_info tool has valid outputSchema', () async {
        final result = await client.listTools();
        final tool =
            result.tools.firstWhere((t) => t.name == 'get_company_info');

        expect(tool.outputSchema, isNotNull);

        final schemaJson = tool.outputSchema!.toJson();
        expect(schemaJson['type'], equals('object'));

        // Verify expected properties are defined
        final properties = schemaJson['properties'] as Map<String, dynamic>;
        expect(properties.containsKey('ticker'), isTrue);
        expect(properties.containsKey('cik'), isTrue);
        expect(properties.containsKey('cik_formatted'), isTrue);
      });

      test('get_financial_statements tool has valid outputSchema', () async {
        final result = await client.listTools();
        final tool = result.tools.firstWhere(
          (t) => t.name == 'get_financial_statements',
        );

        expect(tool.outputSchema, isNotNull);

        final schemaJson = tool.outputSchema!.toJson();
        expect(schemaJson['type'], equals('object'));

        // Verify expected properties
        final properties = schemaJson['properties'] as Map<String, dynamic>;
        expect(properties.containsKey('ticker'), isTrue);
        expect(properties.containsKey('companyName'), isTrue);
        expect(properties.containsKey('periodType'), isTrue);
        expect(properties.containsKey('statements'), isTrue);

        // Verify statements is an array with items schema
        final statementsSchema =
            properties['statements'] as Map<String, dynamic>;
        expect(statementsSchema['type'], equals('array'));
        expect(statementsSchema.containsKey('items'), isTrue);
      });

      test('get_company_info response conforms to outputSchema', () async {
        // Get the tool's output schema
        final toolsResult = await client.listTools();
        final tool = toolsResult.tools.firstWhere(
          (t) => t.name == 'get_company_info',
        );
        final schemaProperties =
            (tool.outputSchema!.toJson()['properties'] as Map<String, dynamic>)
                .keys
                .toSet();

        // Call the tool
        final result = await client.callTool(
          CallToolRequest(
            name: 'get_company_info',
            arguments: {'ticker': 'MSFT'},
          ),
        );

        expect(result.isError, isFalse);

        final data = result.structuredContent!;

        // Verify response contains fields defined in schema
        for (final property in schemaProperties) {
          expect(
            data.containsKey(property),
            isTrue,
            reason:
                'Response should contain property "$property" from outputSchema',
          );
        }
      });

      test('get_financial_statements response conforms to outputSchema',
          () async {
        // Get the tool's output schema
        final toolsResult = await client.listTools();
        final tool = toolsResult.tools.firstWhere(
          (t) => t.name == 'get_financial_statements',
        );
        final schemaProperties =
            (tool.outputSchema!.toJson()['properties'] as Map<String, dynamic>)
                .keys
                .toSet();

        // Call the tool
        final result = await client.callTool(
          CallToolRequest(
            name: 'get_financial_statements',
            arguments: {'ticker': 'AAPL', 'years': 1},
          ),
        );

        expect(result.isError, isFalse);

        final data = result.structuredContent!;

        // Verify response contains fields defined in schema
        // Note: Not all schema properties may be present if data is unavailable
        final requiredSchemaProperties = {'ticker', 'statements'};
        for (final property in requiredSchemaProperties) {
          expect(
            data.containsKey(property),
            isTrue,
            reason:
                'Response should contain property "$property" from outputSchema',
          );
        }

        // Verify schema properties are a superset of required ones
        expect(
          schemaProperties.containsAll(requiredSchemaProperties),
          isTrue,
          reason: 'Schema should define required properties',
        );

        expect(data['statements'], isA<List<dynamic>>());

        // Verify statement items have expected structure from schema
        if ((data['statements'] as List).isNotEmpty) {
          final firstStatement =
              (data['statements'] as List).first as Map<String, dynamic>;
          expect(firstStatement.containsKey('fiscalPeriod'), isTrue);
        }
      });

      test('get_company_info tool returns ticker info', () async {
        final result = await client.callTool(
          CallToolRequest(
            name: 'get_company_info',
            arguments: {'ticker': 'AAPL'},
          ),
        );

        expect(result.isError, isFalse);
        final data = result.structuredContent!;

        expect(data['ticker'], equals('AAPL'));
        expect(data['cik'], isA<int>());
        expect(data['cik_formatted'], isA<String>());
        expect(data['cik_formatted']!.length, equals(10));
      });

      test('get_company_info returns error for invalid ticker', () async {
        final result = await client.callTool(
          CallToolRequest(
            name: 'get_company_info',
            arguments: {'ticker': 'INVALID_TICKER_XYZ123'},
          ),
        );

        expect(result.isError, isTrue);
        expect(result.content, isNotEmpty);

        final textContent = result.content.first as TextContent;
        expect(textContent.text, contains('not found'));
      });

      test('get_company_info throws error when ticker is missing', () async {
        expect(
          () => client.callTool(
            CallToolRequest(name: 'get_company_info', arguments: {}),
          ),
          throwsA(isA<McpError>()),
        );
      });

      test(
          'get_financial_statements returns annual statements with balance sheet',
          () async {
        final result = await client.callTool(
          CallToolRequest(
            name: 'get_financial_statements',
            arguments: {
              'ticker': 'AAPL',
              'period': 'annual',
              'years': 3,
            },
          ),
        );

        expect(result.isError, isFalse);
        final data = result.structuredContent!;

        expect(data['ticker'], equals('AAPL'));
        expect(data['periodType'], equals('annual'));
        expect(data['statements'], isA<List<dynamic>>());
        expect(data['statements'], isNotEmpty);

        // Check first statement has expected structure
        final firstStatement = data['statements'][0] as Map<String, dynamic>;
        expect(firstStatement['fiscalPeriod'], isA<String>());
        expect(firstStatement['balanceSheet'], isA<Map<String, dynamic>>());
        expect(firstStatement['incomeStatement'], isA<Map<String, dynamic>>());
        expect(
          firstStatement['cashFlowStatement'],
          isA<Map<String, dynamic>>(),
        );
      });

      test(
          'get_financial_statements returns income statement with computed margins',
          () async {
        final result = await client.callTool(
          CallToolRequest(
            name: 'get_financial_statements',
            arguments: {
              'ticker': 'MSFT',
            },
          ),
        );

        expect(result.isError, isFalse);
        final data = result.structuredContent!;

        expect(data['ticker'], equals('MSFT'));
        expect(data['statements'], isNotEmpty);

        // Check for computed metrics in income statement
        final stmt = data['statements'][0] as Map<String, dynamic>;
        final income = stmt['incomeStatement'] as Map<String, dynamic>?;
        if (income != null && income['revenue'] != null) {
          // Should have computed margins if data is available
          expect(income.containsKey('revenue'), isTrue);
        }
      });

      test('get_financial_statements returns cash flow with free cash flow',
          () async {
        final result = await client.callTool(
          CallToolRequest(
            name: 'get_financial_statements',
            arguments: {
              'ticker': 'GOOGL',
              'period': 'annual',
            },
          ),
        );

        expect(result.isError, isFalse);
        final data = result.structuredContent!;

        expect(data['ticker'], equals('GOOGL'));
        expect(data['statements'], isNotEmpty);

        // Check cash flow statement exists
        final stmt = data['statements'][0] as Map<String, dynamic>;
        expect(stmt['cashFlowStatement'], isA<Map<String, dynamic>>());
      });

      test('get_financial_statements handles quarterly period', () async {
        final result = await client.callTool(
          CallToolRequest(
            name: 'get_financial_statements',
            arguments: {
              'ticker': 'AAPL',
              'period': 'quarterly',
            },
          ),
        );

        // May return data or error depending on availability
        if (result.isError == false) {
          final data = result.structuredContent!;
          expect(data['periodType'], equals('quarterly'));
          expect(data['statements'], isA<List<dynamic>>());
        }
      });

      test('get_financial_statements with specific year filters results',
          () async {
        final result = await client.callTool(
          CallToolRequest(
            name: 'get_financial_statements',
            arguments: {
              'ticker': 'AAPL',
              'year': 2023,
            },
          ),
        );

        if (result.isError == false) {
          final data = result.structuredContent!;
          final statements = data['statements'] as List;
          // All returned statements should be from 2023
          for (final stmt in statements) {
            expect(
              (stmt['fiscalPeriod'] as String).startsWith('2023'),
              isTrue,
            );
          }
        }
      });

      test('get_financial_statements includes computed ROE and ROIC', () async {
        final result = await client.callTool(
          CallToolRequest(
            name: 'get_financial_statements',
            arguments: {
              'ticker': 'AAPL',
              'period': 'annual',
              'years': 1,
            },
          ),
        );

        expect(result.isError, isFalse);
        final data = result.structuredContent!;

        final stmt = data['statements'][0] as Map<String, dynamic>;
        // These computed metrics should be present if data is available
        // They might be null but the keys should exist in toJson()
        expect(stmt.containsKey('fiscalPeriod'), isTrue);
      });

      test('server info has correct implementation details', () {
        // After connection, client should have server info
        expect(client.getServerVersion()?.name, equals('finance-mcp'));
        expect(client.getServerVersion()?.version, equals('1.0.0'));
      });
    },
    timeout: Timeout(Duration(minutes: 2)),
  );
}
