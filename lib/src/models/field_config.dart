/// Configuration for a single field to extract
class FieldConfig {
  /// Unique field identifier (used as key in result Map)
  final String id;
  
  /// Names to look for in raw text (pipe-separated)
  /// Example: "name||Name||full_name"
  final String contentName;
  
  /// Data type: "String", "int", "double", "bool", "DateTime"
  final String type;
  
  /// Regex pattern to extract the value
  final String regex;
  
  /// Whether regex matching is case-sensitive
  final bool caseSensitive;

  FieldConfig({
    required this.id,
    required this.contentName,
    required this.type,
    required this.regex,
    this.caseSensitive = false,
  });

  /// Create from JSON
  factory FieldConfig.fromJson(Map<String, dynamic> json) {
    return FieldConfig(
      id: json['id'] as String,
      contentName: json['content_name'] as String,
      type: json['type'] as String? ?? 'String',
      regex: json['regex'] as String,
      caseSensitive: json['caseSensitive'] as bool? ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'content_name': contentName,
    'type': type,
    'regex': regex,
    'caseSensitive': caseSensitive,
  };

  @override
  String toString() => 'FieldConfig($id: $contentName)';
}
