import 'dart:io';

import 'package:finance_mcp/data/data.dart';
import 'package:finance_mcp/mcp/mcp.dart';
import 'package:logging/logging.dart' as logging;
import 'package:mcp_dart/mcp_dart.dart';

void main(List<String> args) async {
  // Setup logging
  logging.Logger.root.level = logging.Level.ALL;
  logging.Logger.root.onRecord.listen((record) {
    stderr.writeln('${record.level.name}: ${record.time}: ${record.message}');
  });

  final logger = logging.Logger('FinanceMcpServer');

  // Create data service (DI - can be swapped for testing)
  final dataService = SecClient();

  // Create server with tool capabilities
  final server = McpServer(
    Implementation(name: 'finance-mcp', version: '1.0.0'),
    options: ServerOptions(
      capabilities: ServerCapabilities(
        tools: ServerCapabilitiesTools(),
      ),
    ),
  );

  // Register all tools
  for (final tool in createAllTools(dataService)) {
    server.registerBaseTool(tool);
  }

  // Start the server with StdioTransport
  final transport = StdioServerTransport();
  await server.connect(transport);
  logger.info('Server started on stdio');
}
