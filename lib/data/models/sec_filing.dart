/// Model representing an SEC EDGAR filing.
///
/// Used to retrieve and parse filings like 8-K, 10-K, 10-Q for
/// sentiment analysis and event detection.
class SecFiling {
  SecFiling({
    required this.accessionNumber,
    required this.form,
    required this.filingDate,
    required this.primaryDocument,
    required this.description,
    required this.cik,
  });

  /// Creates a SecFiling from SEC submissions API JSON.
  factory SecFiling.fromJson(Map<String, dynamic> json, int cik) {
    return SecFiling(
      accessionNumber: json['accessionNumber'] as String,
      form: json['form'] as String,
      filingDate: DateTime.parse(json['filingDate'] as String),
      primaryDocument: json['primaryDocument'] as String,
      description: (json['primaryDocDescription'] as String?) ?? '',
      cik: cik,
    );
  }

  /// Unique SEC filing identifier (e.g., "0000320193-24-000123").
  final String accessionNumber;

  /// Filing form type (e.g., "8-K", "10-K", "10-Q").
  final String form;

  /// Date the filing was submitted to SEC.
  final DateTime filingDate;

  /// Filename of the primary document in the filing.
  final String primaryDocument;

  /// Brief description of the filing.
  final String description;

  /// Company's CIK number.
  final int cik;

  /// Content of the filing (populated when fetched).
  String? content;

  /// URL to the filing on SEC EDGAR.
  String get url {
    final accessionNoHyphens = accessionNumber.replaceAll('-', '');
    final cikStr = cik.toString();
    return 'https://www.sec.gov/Archives/edgar/data/$cikStr/$accessionNoHyphens/$primaryDocument';
  }

  /// Converts this filing to JSON.
  Map<String, dynamic> toJson() => {
        'accessionNumber': accessionNumber,
        'form': form,
        'filingDate': filingDate.toIso8601String().split('T').first,
        'primaryDocument': primaryDocument,
        'description': description,
        'url': url,
        if (content != null) 'content': content,
      };

  @override
  String toString() => 'SecFiling($form, $filingDate, $accessionNumber)';
}
