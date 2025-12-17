/// Finance MCP Server entry point.
///
/// Supports both stdio (default) and StreamableHTTP transports.
///
/// Usage:
///   dart run bin/server.dart [options]
///
/// Options:
///   -t, --transport    Transport type: stdio (default) or http
///   -h, --host         Host for HTTP transport (default: 0.0.0.0)
///   -p, --port         Port for HTTP transport (default: 3000)
///       --path         Endpoint path for HTTP transport (default: /mcp)
///       --help         Show usage information
library;

import 'dart:io';

import 'package:finance_mcp/data/data.dart';
import 'package:finance_mcp/mcp/mcp.dart';
import 'package:finance_mcp/mcp/server_config.dart';
import 'package:logging/logging.dart' as logging;
import 'package:mcp_dart/mcp_dart.dart';

void main(List<String> args) async {
  try {
    final config = ServerConfig.fromArgs(args);

    if (config.help) {
      ServerConfig.printUsage();
      return;
    }

    _setupLogging(config.verbose);
    final logger = logging.Logger('FinanceMcpServer');
    final dataService = SecClient();

    switch (config.transport) {
      case TransportType.stdio:
        await _runStdioServer(dataService, logger);
      case TransportType.http:
        await _runHttpServer(
          dataService,
          logger,
          host: config.host,
          port: config.port,
          path: config.path,
        );
    }
  } on FormatException catch (e) {
    stderr.writeln('Error: ${e.message}');
    ServerConfig.printUsage();
    exit(1);
  }
}

void _setupLogging(bool verbose) {
  logging.Logger.root.level = verbose ? logging.Level.ALL : logging.Level.INFO;
  logging.Logger.root.onRecord.listen((record) {
    stderr.writeln('${record.level.name}: ${record.time}: ${record.message}');
  });
}

Future<void> _runStdioServer(
  FinancialDataService dataService,
  logging.Logger logger,
) async {
  final server = createMcpServer(dataService);
  final transport = StdioServerTransport();
  await server.connect(transport);
  logger.info('Server started on stdio');
}

Future<void> _runHttpServer(
  FinancialDataService dataService,
  logging.Logger logger, {
  required String host,
  required int port,
  required String path,
}) async {
  final server = StreamableMcpServer(
    serverFactory: (sessionId) {
      logger.fine('New session: $sessionId');
      return createMcpServer(dataService);
    },
    host: host,
    port: port,
    path: path,
    eventStore: InMemoryEventStore(),
  );

  await server.start();
  logger.info('StreamableHTTP server running at http://$host:$port$path');
}
