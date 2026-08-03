import 'dart:convert';

/// Model to represent field configuration for dynamic extraction
class FieldConfig {
  final String id;
  final String label;
  final String hintText;
  final String type; // text, number, email, phone
  final String icon;
  final List<String> patterns;
  final String regex;
  final bool caseSensitive;
  final int maxLines;

  FieldConfig({
    required this.id,
    required this.label,
    required this.hintText,
    required this.type,
    required this.icon,
    required this.patterns,
    required this.regex,
    required this.caseSensitive,
    required this.maxLines,
  });

  /// Create from JSON
  factory FieldConfig.fromJson(Map<String, dynamic> json) {
    return FieldConfig(
      id: json['id'] as String,
      label: json['label'] as String,
      hintText: json['hintText'] as String,
      type: json['type'] as String? ?? 'text',
      icon: json['icon'] as String? ?? 'text_fields',
      patterns: List<String>.from(json['patterns'] as List? ?? []),
      regex: json['regex'] as String,
      caseSensitive: json['caseSensitive'] as bool? ?? false,
      maxLines: json['maxLines'] as int? ?? 1,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'hintText': hintText,
    'type': type,
    'icon': icon,
    'patterns': patterns,
    'regex': regex,
    'caseSensitive': caseSensitive,
    'maxLines': maxLines,
  };

  @override
  String toString() => 'FieldConfig(id: $id, label: $label, type: $type)';
}

/// Configuration container
class FieldsConfiguration {
  final List<FieldConfig> fields;

  FieldsConfiguration({required this.fields});

  /// Create from JSON
  factory FieldsConfiguration.fromJson(Map<String, dynamic> json) {
    final fieldsList = (json['fields'] as List?)
        ?.map((e) => FieldConfig.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];
    return FieldsConfiguration(fields: fieldsList);
  }

  /// Create from JSON string
  factory FieldsConfiguration.fromJsonString(String jsonString) {
    return FieldsConfiguration.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'fields': fields.map((f) => f.toJson()).toList(),
  };

  /// Get field config by ID
  FieldConfig? getFieldById(String id) {
    try {
      return fields.firstWhere((f) => f.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get all field IDs
  List<String> getFieldIds() => fields.map((f) => f.id).toList();

  @override
  String toString() => 'FieldsConfiguration(fields: ${fields.length})';
}
