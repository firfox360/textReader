import 'package:flutter/foundation.dart';
import '../models/field_config.dart';

/// Extracts structured data from text using regex patterns

class TextExtractor {
  final List<FieldConfig> fieldConfigs;

  TextExtractor({required this.fieldConfigs});

  /// Extract all fields from raw text
  /// Example output:
  /// {
  ///   'name': 'John Doe',
  ///   'phone': 'MM19779347',
  ///   'email': 'john@example.com',
  ///   'age': 28
  /// }
  Map<String, dynamic> extractFields(String rawText) {
    final extracted = <String, dynamic>{};

    if (rawText.isEmpty) {
      if (kDebugMode) {
        debugPrint('⚠️ Empty raw text provided');
      }
      return extracted;
    }

    for (final fieldConfig in fieldConfigs) {
      try {
        final value = _extractField(rawText, fieldConfig);
        if (value != null) {
          final converted = _convertType(value, fieldConfig.type);
          extracted[fieldConfig.id] = converted;

          if (kDebugMode) {
            debugPrint(
              '✅ Extracted ${fieldConfig.id}: $converted (${converted.runtimeType})',
            );
          }
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ Error extracting ${fieldConfig.id}: $e');
        }
      }
    }

    if (kDebugMode) {
      debugPrint('📊 Total fields extracted: ${extracted.length}');
    }

    return extracted;
  }

  /// Extract single field value using regex
  String? _extractField(String text, FieldConfig config) {
    try {
      final pattern = RegExp(
        config.regex,
        caseSensitive: config.caseSensitive,
        multiLine: true,
        dotAll: true,
      );

      final match = pattern.firstMatch(text);
      if (match != null && match.groupCount > 0) {
        return match.group(1)?.trim();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Regex error for ${config.id}: $e');
      }
    }
    return null;
  }

  /// Convert string value to proper type
  dynamic _convertType(String value, String type) {
    try {
      switch (type.toLowerCase()) {
        case 'int':
          return int.tryParse(value);
        case 'double':
          return double.tryParse(value);
        case 'bool':
          return value.toLowerCase() == 'true' || value == '1';
        case 'datetime':
          return DateTime.tryParse(value);
        default:
          return value; // String
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Type conversion error: $e');
      }
      return value; // Fallback to string
    }
  }
}
