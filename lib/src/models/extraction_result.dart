/// Result of extraction operation
/// Contains extracted data as Map<String, dynamic> with field IDs as keys
class ExtractionResult {
  /// Extracted data: Map<fieldId, value>
  /// Example: {'name': 'John Doe', 'phone': 'MM19779347'}
  final Map<String, dynamic> data;
  
  /// Original raw OCR text
  final String rawText;
  
  /// When extraction happened
  final DateTime extractedAt;
  
  /// Whether extraction was successful
  final bool success;
  
  /// Any errors that occurred
  final List<String> errors;

  ExtractionResult({
    required this.data,
    required this.rawText,
    required this.extractedAt,
    this.success = true,
    this.errors = const [],
  });

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
    'data': data,
    'rawText': rawText,
    'extractedAt': extractedAt.toIso8601String(),
    'success': success,
  };

  /// Pretty print the result
  String prettyPrint() {
    return '''
╔════════════════════════════════════════════════════════════════╗
║                    EXTRACTION RESULT                           ║
╚════════════════════════════════════════════════════════════════╝

✓ SUCCESS: $success
📅 EXTRACTED AT: $extractedAt

📊 EXTRACTED DATA (Map<String, dynamic>):
${data.entries.map((e) => '  ${e.key}: ${e.value}').join('\n')}

📝 RAW TEXT:
$rawText

${errors.isNotEmpty ? '❌ ERRORS:\n${errors.map((e) => '  - $e').join('\n')}' : ''}
''';
  }
}
