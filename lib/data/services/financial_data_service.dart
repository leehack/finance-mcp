import '../models/company_financials.dart';
import '../models/metric_history.dart';
import '../models/sec_filing.dart';

/// Abstract interface for financial data access.
///
/// This enables dependency injection and allows swapping implementations
/// (e.g., real SEC client vs. mock for testing).
abstract class FinancialDataService {
  /// Get the CIK (Central Index Key) for a ticker symbol.
  Future<int?> getCik(String ticker);

  /// Get raw company facts from SEC EDGAR.
  Future<Map<String, dynamic>> getCompanyFacts(String ticker);

  /// Fetch historical financial data for a company.
  ///
  /// Returns structured [CompanyFinancials] with up to [years] years of data.
  /// Set [includeQuarterly] to true to include Q1-Q4 data.
  Future<CompanyFinancials> getHistoricalFinancials(
    String ticker, {
    int years = 10,
    bool includeQuarterly = true,
    Set<FinancialMetric>? metrics,
  });

  /// Fetch recent SEC filings for a company.
  ///
  /// [forms] filters by form type (e.g., ['8-K', '10-K']).
  /// [limit] caps the number of filings returned.
  Future<List<SecFiling>> getRecentFilings(
    String ticker, {
    List<String>? forms,
    int limit = 10,
  });

  /// Fetch the text content of a specific filing.
  ///
  /// Returns the text extracted from the filing document.
  Future<String> getFilingContent(SecFiling filing);

  /// Close any underlying resources (e.g., HTTP client).
  void close();
}
