/// Factory for creating configured MCP server instances.
library;

import 'package:mcp_dart/mcp_dart.dart';

import '../data/data.dart';
import 'mcp.dart';

/// Creates a fully configured MCP server instance.
///
/// The [dataService] is injected for tool implementations.
/// This factory can be used with any transport (Stdio, StreamableHTTP).
McpServer createMcpServer(FinancialDataService dataService) {
  final server = McpServer(
    Implementation(name: 'finance-mcp', version: '1.0.0'),
    options: ServerOptions(
      capabilities: ServerCapabilities(
        tools: ServerCapabilitiesTools(),
        prompts: ServerCapabilitiesPrompts(),
      ),
    ),
  );

  // Register all tools
  for (final tool in createAllTools(dataService)) {
    server.registerBaseTool(tool);
  }

  // Register all prompts
  for (final prompt in createAllPrompts()) {
    server.registerBasePrompt(prompt);
  }

  // Register all resources
  for (final resource in createAllResources()) {
    server.registerBaseResource(resource);
  }

  return server;
}
