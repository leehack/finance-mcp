# Finance MCP Server

A Model Context Protocol (MCP) server written in Dart that fetches financial statements and company data from SEC EDGAR.

## Features

- **Fetch Company Info**: Get CIK and metadata for a ticker.
- **Fetch Financial Statements**: Retrieve Balance Sheet, Income Statement, and Cash Flow data (Annual/Quarterly).
- **SEC Integration**: Compliant with SEC EDGAR API requirements (User-Agent).

## Tools

1.  `get_company_info(ticker: string)`
2.  `get_financial_statements(ticker: string, statement_type: string, period: string?, year: int?)`

## Prerequisites

- Dart SDK (>=3.0.0)

## Setup

1.  Install dependencies:
    ```bash
    dart pub get
    ```

## Usage

### Running the Server

To run the server directly (uses Stdio transport):

```bash
dart run bin/server.dart
```

### Compiling to Executable

For better performance or distribution:

```bash
dart compile exe bin/server.dart -o finance_mcp
./finance_mcp
```

### Configuration (e.g., for Claude Desktop)

Add the following to your `mcp.json` (usually in `~/Library/Application Support/Claude/mcp.json` on macOS):

```json
{
  "mcpServers": {
    "finance": {
      "command": "dart",
      "args": ["run", "/absolute/path/to/finance-mcp/bin/server.dart"]
    }
  }
}
```

Or if compiled:

```json
{
  "mcpServers": {
    "finance": {
      "command": "/absolute/path/to/finance-mcp/finance_mcp",
      "args": []
    }
  }
}
```

## Testing

Run the manual integration test to verify SEC data fetching:

```bash
dart run test/manual_test.dart
```
