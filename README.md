# Finance MCP Server

A Model Context Protocol (MCP) server written in Dart that provides financial data and analysis tools from SEC EDGAR.

This server exposes tools to fetch company information and financial statements, as well as prompts to guide LLMs in performing financial analysis.

## Features

- **Fetch Company Info**: Get CIK, name, and tickers for a company.
- **Fetch Financial Statements**: Retrieve Balance Sheets, Income Statements, and Cash Flows (Annual/Quarterly) with up to 10 years of history.
- **Fetch SEC Filings**: Access 8-K, 10-K, and 10-Q filings for sentiment analysis.
- **Financial Analysis Prompts**: Built-in templates for comprehensive company analysis and stock comparisons.
- **Multiple Transports**: Supports both `stdio` (default) and `StreamableHTTP` (SSE/Post) transports.
- **Modular Architecture**: Clean separation of data, MCP protocol, and server logic.
- **SEC Integration**: Compliant with SEC EDGAR API requirements (User-Agent).

## Tools

The server exposes the following tools:

1.  **`get_company_info(ticker: string)`**
    *   Retrieves metadata (CIK, name) for a given stock ticker.
2.  **`get_financial_statements(ticker: string, period: string?, year: int?, years: int?)`**
    *   Fetches comprehensive financial statements (Income, Balance Sheet, Cash Flow) with computed metrics (ROE, ROIC).
    *   `period`: `annual` (default) or `quarterly`.
    *   `year`: Optional specific year to retrieve.
    *   `years`: Number of historical years to fetch (default: 5).
3.  **`get_sec_filings(ticker: string, forms: string[]?, limit: int?, includeContent: bool?)`**
    *   Retrieves SEC EDGAR filings lists and optionally full text content.
    *   `forms`: List of form types (e.g., `['8-K', '10-K']`).
    *   `includeContent`: If true, fetches the full text body of the filings (useful for sentiment analysis).

## Prompts

The server provides structured prompts to help LLMs generate financial insights:

1.  **`comprehensive_analysis`**
    *   Generates a complete stock analysis covering financial health (profitability, balance sheet, cash flow), intrinsic value (DCF, P/E, ROE models), business quality (moat, management), sentiment (SEC filings, news), and an actionable investment thesis.
2.  **`compare_stocks`**
    *   Performs a side-by-side comparative analysis of multiple stocks across financial health, valuation, business quality, and sentiment.

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
