/// MCP resources for the finance-mcp server.
///
/// This library provides modular resource implementations that can be registered
/// with any MCP server, regardless of transport type (stdio, StreamableHTTP).
///
/// Resources allow exposing data that LLMs can read directly.
library;

// No FinancialDataService dependency needed until resources are implemented
// import '../../data/services/financial_data_service.dart';
import 'base_resource.dart';

export 'base_resource.dart';

// Export future resource implementations here:
// export 'company_list_resource.dart';
// export 'financial_summary_resource.dart';

/// Creates all available resources.
///
/// Use this to register all resources with an MCP server:
/// ```dart
/// final resources = createAllResources();
/// for (final resource in resources) {
///   server.registerBaseResource(resource);
/// }
/// ```
List<BaseResource> createAllResources() => [
      // Add resource implementations here when created
    ];
