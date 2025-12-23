# Finance MCP Server Example

This package provides a Model Context Protocol (MCP) server for retrieving financial data.

## Running the Server

You can run the server using the `dart run` command:

```bash
# Run with default Stdio transport (best for Claude Desktop)
dart run bin/server.dart

# Run with HTTP transport
dart run bin/server.dart --transport http --port 3000
```

## Using with MCP Clients

### Claude Desktop

Add the following to your `mcp.json` configuration:

```json
{
  "mcpServers": {
    "finance-mcp": {
      "command": "dart",
      "args": ["run", "/path/to/finance-mcp/bin/server.dart"]
    }
  }
}
```

## Available Tools

Once connected, the server exposes the following tools to the LLM:

- `get_company_info(ticker)`: Get CIK and company name.
- `get_financial_statements(ticker, year, years)`: Get balance sheets, income statements, and cash flows.
- `get_sec_filings(ticker, forms)`: Get recent 8-K, 10-K, etc. filings.
