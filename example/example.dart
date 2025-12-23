import 'package:finance_mcp/data/data.dart';
import 'package:finance_mcp/mcp/mcp.dart';

void main() async {
  // 1. Initialize the financial data service
  final dataService = SecClient();

  // 2. Create the MCP server
  final server = createMcpServer(dataService);

  print('Finance MCP Server initialized.');
  print('Available tools:');

  // Note: specific tool inspection depends on the McpServer implementation detail
  // but for an example, just instantiating it is sufficient.
  // In a real app, you would connect it to a transport:
  // await server.connect(StdioServerTransport());
}
