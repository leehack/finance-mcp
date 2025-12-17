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

import 'package:args/args.dart';
import 'package:finance_mcp/data/data.dart';
import 'package:finance_mcp/mcp/mcp.dart';
import 'package:logging/logging.dart' as logging;
import 'package:mcp_dart/mcp_dart.dart';

void main(List<String> args) async {
  final parser = _buildArgParser();

  try {
    final results = parser.parse(args);

    if (results.flag('help')) {
      _printUsage(parser);
      return;
    }

    _setupLogging(results.flag('verbose'));
    final logger = logging.Logger('FinanceMcpServer');

    final transport = results.option('transport')!;
    final dataService = SecClient();

    switch (transport) {
      case 'stdio':
        await _runStdioServer(dataService, logger);
      case 'http':
        await _runHttpServer(
          dataService,
          logger,
          host: results.option('host')!,
          port: int.parse(results.option('port')!),
          path: results.option('path')!,
        );
      default:
        stderr.writeln('Unknown transport: $transport');
        _printUsage(parser);
        exit(1);
    }
  } on FormatException catch (e) {
    stderr.writeln('Error: ${e.message}');
    _printUsage(parser);
    exit(1);
  }
}

ArgParser _buildArgParser() {
  return ArgParser()
    ..addOption(
      'transport',
      abbr: 't',
      help: 'Transport type to use.',
      allowed: ['stdio', 'http'],
      defaultsTo: 'stdio',
    )
    ..addOption(
      'host',
      abbr: 'h',
      help: 'Host to bind for HTTP transport.',
      defaultsTo: '0.0.0.0',
    )
    ..addOption(
      'port',
      abbr: 'p',
      help: 'Port to bind for HTTP transport.',
      defaultsTo: '3000',
    )
    ..addOption(
      'path',
      help: 'Endpoint path for HTTP transport.',
      defaultsTo: '/mcp',
    )
    ..addFlag(
      'verbose',
      abbr: 'v',
      help: 'Enable verbose logging.',
      negatable: false,
    )
    ..addFlag(
      'help',
      help: 'Show this help message.',
      negatable: false,
    );
}

void _printUsage(ArgParser parser) {
  stderr
    ..writeln('Finance MCP Server')
    ..writeln()
    ..writeln('Usage: dart run bin/server.dart [options]')
    ..writeln()
    ..writeln('Options:')
    ..writeln(parser.usage)
    ..writeln()
    ..writeln('Examples:')
    ..writeln(
      '  dart run bin/server.dart                          # stdio transport',
    )
    ..writeln(
      '  dart run bin/server.dart -t http                  # HTTP on 0.0.0.0:3000',
    )
    ..writeln(
      '  dart run bin/server.dart -t http -p 8080          # HTTP on port 8080',
    )
    ..writeln(
      '  dart run bin/server.dart -t http -h localhost     # HTTP on localhost only',
    );
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
