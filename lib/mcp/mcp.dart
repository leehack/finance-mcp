/// MCP protocol components for the finance-mcp server.
///
/// This library centralizes all MCP-related code including:
/// - Tools: Actions that LLMs can invoke
/// - Prompts: Structured input templates for common tasks
/// - Resources: Data that LLMs can read
library;

export 'prompts/prompts.dart';
export 'resources/resources.dart';
export 'server_factory.dart';
export 'tools/tools.dart';
