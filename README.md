# Finance MCP Server

A Model Context Protocol (MCP) server written in Dart that integrates with SEC EDGAR to provide comprehensive financial data and analysis tools for Large Language Models.

This server enables LLMs to fetch company metadata, historical financial statements (up to 10 years), and SEC filings (10-K, 10-Q, 8-K) for sentiment analysis and fundamental research.

## Features

- **Company Metadata**: Resolve tickers to CIKs and company names.
- **Financial Statements**: Retrieve up to 10 years of Balance Sheets, Income Statements, and Cash Flows with computed metrics (ROE, ROIC).
- **SEC Filings**: Access full text content of 8-K, 10-K, and 10-Q filings for sentiment analysis (compliant with SEC User-Agent requirements).
- **Analysis Prompts**: Built-in prompts for `comprehensive_analysis` and `compare_stocks` to guide LLMs in structured financial reporting.
- **Flexible Transports**: Supports `stdio` (default) for local clients and `http` (SSE) for remote deployment.
- **Docker Support**: Ready-to-use Dockerfile for containerized deployment.

## Installation

### Option 1: Global Activation (Recommended)

Install globally from pub.dev to use the CLI anywhere:

```bash
dart pub global activate finance_mcp
```

### Option 2: From Source

For development or contributing:

```bash
git clone https://github.com/leehack/finance-mcp.git
cd finance_mcp
dart pub get
```

## Usage

### Running the Server

**1. Stdio Transport (Default)**
Ideal for local use with clients like Claude Desktop.

```bash
# If installed globally:
finance_mcp
# OR
dart pub global run finance_mcp

# If from source:
dart run bin/server.dart
```

**2. HTTP Transport (SSE)**
Exposes an SSE endpoint for remote connections.

```bash
dart run bin/server.dart --transport http --port 3000
```
The server will listen on `http://0.0.0.0:3000/mcp`.

## Configuration

To use with [Claude Desktop](https://claude.ai/download), add the following to your `mcp.json`:

### 1. Using Global Installation (Simplest)

```json
{
  "mcpServers": {
    "finance-mcp": {
      "command": "dart",
      "args": ["pub", "global", "run", "finance_mcp"]
    }
  }
}
```

### 2. Using Docker

```json
{
  "mcpServers": {
    "finance-mcp": {
      "command": "docker",
      "args": ["run", "-i", "--rm", "finance-mcp"]
    }
  }
}
```

### 3. Using Source (Development)

```json
{
  "mcpServers": {
    "finance-mcp": {
      "command": "dart",
      "args": ["run", "/ABSOLUTE/PATH/TO/finance-mcp/bin/server.dart"]
    }
  }
}
```

### Advanced: Auto-Updating Global Install

To automatically update `finance_mcp` every time you run it (adds latency):

<details>
<summary>Click to see configuration</summary>

**macOS / Linux**:
```json
{
  "mcpServers": {
    "finance-mcp": {
      "command": "/bin/sh",
      "args": [
        "-c",
        "dart pub global activate finance_mcp 1>&2 && $HOME/.pub-cache/bin/finance_mcp"
      ]
    }
  }
}
```

**Windows**:
```json
{
  "mcpServers": {
    "finance-mcp": {
      "command": "cmd.exe",
      "args": [
        "/c",
        "dart pub global activate finance_mcp > NUL && %LOCALAPPDATA%\\Pub\\Cache\\bin\\finance_mcp.bat"
      ]
    }
  }
}
```
</details>

## Available Tools

- **`get_company_info`**:
  - `ticker`: Stock ticker symbol (e.g., AAPL).
  - Returns CIK, name, and exchange info.

- **`get_financial_statements`**:
  - `ticker`: Stock ticker symbol.
  - `period`: `annual` or `quarterly` (default: annual).
  - `year`: Specific year (optional).
  - `years`: Number of years to fetch (default: 5).
  - Returns structured JSON of financial statements.

- **`get_sec_filings`**:
  - `ticker`: Stock ticker symbol.
  - `forms`: List of forms to fetch (e.g., `["10-K", "8-K"]`).
  - `limit`: Max number of filings.
  - `includeContent`: Boolean to fetch full text body (default: false).

## Development

Run tests:
```bash
dart test
```

## License

See [LICENSE](LICENSE).
