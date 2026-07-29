import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

/// Model for dynamic field configuration
class DynamicFieldConfig {
  final String id;
  final String contentName; // "name||Name||nombre"
  final String type; // "String", "int", "bool", etc.
  final String regex;
  final bool caseSensitive;

  DynamicFieldConfig({
    required this.id,
    required this.contentName,
    required this.type,
    required this.regex,
    required this.caseSensitive,
  });

  factory DynamicFieldConfig.fromJson(Map<String, dynamic> json) {
    return DynamicFieldConfig(
      id: json['id'] as String,
      contentName: json['content_name'] as String? ?? '',
      type: json['type'] as String? ?? 'String',
      regex: json['regex'] as String? ?? '',
      caseSensitive: json['caseSensitive'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'content_name': contentName,
    'type': type,
    'regex': regex,
    'caseSensitive': caseSensitive,
  };

  @override
  String toString() => 'DynamicFieldConfig(id: $id, type: $type)';
}

/// Configuration holder
class FieldsConfiguration {
  final String version;
  final List<DynamicFieldConfig> fields;

  FieldsConfiguration({
    required this.version,
    required this.fields,
  });

  factory FieldsConfiguration.fromJson(Map<String, dynamic> json) {
    return FieldsConfiguration(
      version: json['version'] as String? ?? '1.0',
      fields: (json['fields'] as List?)
          ?.map((f) => DynamicFieldConfig.fromJson(f as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  factory FieldsConfiguration.fromJsonString(String jsonString) {
    return FieldsConfiguration.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
    'version': version,
    'fields': fields.map((f) => f.toJson()).toList(),
  };

  String toJsonString() => jsonEncode(toJson());

  DynamicFieldConfig? getFieldById(String fieldId) {
    try {
      return fields.firstWhere((f) => f.id == fieldId);
    } catch (e) {
      return null;
    }
  }
}

/// Dynamic field extraction service
/// Reads field_config.json and extracts fields dynamically
class DynamicFieldService {
  static final DynamicFieldService _instance = DynamicFieldService._internal();
  late FieldsConfiguration config;
  bool _initialized = false;

  factory DynamicFieldService() {
    return _instance;
  }

  DynamicFieldService._internal();

  /// Initialize configuration from assets
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final jsonString = await rootBundle.loadString('assets/field_config.json');
      config = FieldsConfiguration.fromJsonString(jsonString);
      _initialized = true;

      if (kDebugMode) {
        print('✅ Dynamic field configuration loaded: ${config.fields.length} fields');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading field config: $e');
      }
      throw Exception('Failed to load field configuration: $e');
    }
  }

  /// Extract all fields dynamically from text based on config
  Map<String, dynamic> extractAllFields(String text) {
    if (text.isEmpty) return {};
    if (!_initialized) {
      throw Exception('Service not initialized. Call initialize() first.');
    }

    final Map<String, dynamic> results = {};

    for (final fieldConfig in config.fields) {
      final value = _extractFieldValue(text, fieldConfig);
      if (value != null) {
        results[fieldConfig.id] = _convertType(value, fieldConfig.type);

        if (kDebugMode) {
          print('✓ ${fieldConfig.id} (${fieldConfig.type}): $value');
        }
      }
    }

    return results;
  }

  /// Extract single field value
  String? _extractFieldValue(String text, DynamicFieldConfig config) {
    try {
      final pattern = RegExp(
        config.regex,
        caseSensitive: config.caseSensitive,
        multiLine: true,
      );

      final match = pattern.firstMatch(text);
      if (match != null) {
        String? value = match.group(1)?.trim();
        return value?.isEmpty ?? true ? null : value;
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error extracting ${config.id}: $e');
      }
    }

    return null;
  }

  /// Convert string value to target type
  dynamic _convertType(String value, String type) {
    try {
      switch (type.toLowerCase()) {
        case 'int':
          return int.tryParse(value) ?? value;
        case 'double':
          return double.tryParse(value) ?? value;
        case 'bool':
          return value.toLowerCase() == 'true' || value == '1';
        case 'datetime':
          return DateTime.tryParse(value) ?? value;
        case 'string':
        default:
          return value;
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Type conversion error ($type): $e');
      }
      return value;
    }
  }

  /// Get all fields configuration
  List<DynamicFieldConfig> getAllFields() => config.fields;

  /// Get field configuration by ID
  DynamicFieldConfig? getFieldById(String fieldId) => config.getFieldById(fieldId);

  /// Add new field to config dynamically
  void addField(DynamicFieldConfig field) {
    if (!config.fields.any((f) => f.id == field.id)) {
      config.fields.add(field);
      if (kDebugMode) {
        print('✅ Field added: ${field.id}');
      }
    }
  }

  /// Update existing field
  void updateField(String fieldId, DynamicFieldConfig newField) {
    final index = config.fields.indexWhere((f) => f.id == fieldId);
    if (index != -1) {
      config.fields[index] = newField;
      if (kDebugMode) {
        print('🔄 Field updated: $fieldId');
      }
    }
  }

  /// Remove field from config
  void removeField(String fieldId) {
    config.fields.removeWhere((f) => f.id == fieldId);
    if (kDebugMode) {
      print('❌ Field removed: $fieldId');
    }
  }

  /// Get debug info
  String getDebugInfo() {
    return '''
═══════════════════════════════════════════════════════════════
🔧 DYNAMIC FIELD SERVICE
═══════════════════════════════════════════════════════════════
Version: ${config.version}
Total Fields: ${config.fields.length}
Initialized: $_initialized

Fields:
${config.fields.map((f) => '  • ${f.id} (${f.type}) - ${f.contentName}').join('\n')}
═══════════════════════════════════════════════════════════════
    ''';
  }
}

/// Dynamic extracted data - flexible structure
class DynamicExtractedData {
  final Map<String, dynamic> data;
  final DateTime extractedAt;
  final String? rawText;

  DynamicExtractedData({
    Map<String, dynamic>? data,
    DateTime? extractedAt,
    this.rawText,
  })  : data = data ?? {},
        extractedAt = extractedAt ?? DateTime.now();

  /// Create from extracted fields
  factory DynamicExtractedData.fromExtractedFields(
    Map<String, dynamic> fields, {
    String? rawText,
  }) {
    return DynamicExtractedData(
      data: fields,
      rawText: rawText,
    );
  }

  /// Get field value
  dynamic getField(String fieldId) => data[fieldId];

  /// Set field value
  void setField(String fieldId, dynamic value) {
    data[fieldId] = value;
  }

  /// Check if field exists
  bool hasField(String fieldId) => data.containsKey(fieldId);

  /// Check if any data exists
  bool hasData() => data.isNotEmpty;

  /// Get field count
  int getFieldCount() => data.length;

  /// Get all fields
  Map<String, dynamic> getAllFields() => Map.from(data);

  /// Convert to JSON Map
  Map<String, dynamic> toJson() {
    final json = Map<String, dynamic>.from(data);
    json['extractedAt'] = extractedAt.toIso8601String();
    if (rawText != null) {
      json['rawText'] = rawText;
    }
    return json;
  }

  /// Convert to JSON string
  String toJsonString() => jsonEncode(toJson());

  /// Create from JSON string
  factory DynamicExtractedData.fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    final rawText = json.remove('rawText') as String?;
    final extractedAtStr = json.remove('extractedAt') as String?;
    
    return DynamicExtractedData(
      data: json,
      extractedAt: extractedAtStr != null ? DateTime.parse(extractedAtStr) : null,
      rawText: rawText,
    );
  }

  /// Clear all data
  void clear() {
    data.clear();
  }

  @override
  String toString() => 'DynamicExtractedData(fields: ${data.length}, at: $extractedAt)';
}
