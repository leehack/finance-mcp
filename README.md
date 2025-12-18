# Finance MCP Server

A Model Context Protocol (MCP) server written in Dart that provides financial data and analysis tools from SEC EDGAR.

This server exposes tools to fetch company information and financial statements, as well as prompts to guide LLMs in performing financial analysis.

## Features

- **Fetch Company Info**: Get CIK, name, and tickers for a company.
- **Fetch Financial Statements**: Retrieve Balance Sheets, Income Statements, and Cash Flows (Annual/Quarterly) with up to 10 years of history.
- **Financial Analysis Prompts**: Built-in templates for analyzing companies, comparing stocks, and valuing assets.
- **Multiple Transports**: Supports both `stdio` (default) and `StreamableHTTP` (SSE/Post) transports.
- **Modular Architecture**: Clean separation of data, MCP protocol, and server logic.
- **SEC Integration**: Compliant with SEC EDGAR API requirements (User-Agent).

## Tools

The server exposes the following tools:

1.  **`get_company_info(ticker: string)`**
    *   Retrieves metadata (CIK, name) for a given stock ticker.
2.  **`get_financial_statements(ticker: string, statement_type: string, period: string?, year: int?)`**
    *   Fetches financial statements.
    *   `statement_type`: `balance_sheet`, `income_statement`, or `cash_flow`.
    *   `period`: `annual` (default) or `quarterly`.
    *   `year`: Optional specific year. Checks recent years if omitted.

## Prompts

The server provides structured prompts to help LLMs generate financial insights:

1.  **`analyze_company`**: Comprehensive financial analysis covering business overview, health, growth, risks, and investment assessment.
2.  **`financial_health`**: Focused deep dive into solvency, liquidity, and profitability metrics.
3.  **`compare_stocks`**: Comparative analysis of two or more companies.
4.  **`investment_thesis`**: Structured framework for building a bull/bear investment case.
5.  **`intrinsic_value`**: Comprehensive intrinsic value analysis combining DCF and Quality (PE, ROE) analysis.

## Prerequisites

- Dart SDK (>=3.0.0)

## Setup

1.  Install dependencies:
    ```bash
    dart pub get
    ```

## Usage

### Running the Server

**Option 1: Stdio Transport (Default)**
Best for local use with Claude Desktop.

```bash
dart run bin/server.dart
```

**Option 2: HTTP Transport**
Exposes an StreamableHTTPS endpoint for remote connections.

```bash
dart run bin/server.dart --transport http --port 3000
```

### Running with Docker

1.  **Build the image:**
    ```bash
    docker build -t finance-mcp .
    ```

### Configuration (Claude Desktop & Other Clients)

#### 1. Docker (Stdio) - Recommended
Run the server in a container managed by the client.

Add to `mcp.json`:
```json
{
  "mcpServers": {
    "finance-docker": {
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--rm",
        "finance-mcp",
        "--transport",
        "stdio"
      ]
    }
  }
}
```

#### 2. Docker (StreamableHTTP)
Run the server independently and connect via HTTP.

1.  Start the container:
    ```bash
    docker run -p 3000:3000 finance-mcp
    ```

2.  Add to `mcp.json`:
    ```json
    {
      "mcpServers": {
        "finance-http": {
          "url": "http://localhost:3000/mcp"
        }
      }
    }
    ```

#### 3. Local Dart (Development)
Run directly from source.

Add to `mcp.json`:
```json
{
  "mcpServers": {
    "finance-local": {
      "command": "dart",
      "args": ["run", "/absolute/path/to/finance-mcp/bin/server.dart"]
    }
  }
}
```


*Note: Replace `/absolute/path/to/finance-mcp` with the actual path to your project.*

## Development

### Running Tests

To run the full test suite (unit and integration tests):

```bash
dart test
```
