# Complete Package Conversion Guide

## Step 1: Create Package Structure

### New Folder Layout

```
textreder/
├── lib/
│   ├── textreder.dart                    ← Main export file
│   └── src/
│       ├── models/
│       │   ├── extraction_result.dart    ← Return model
│       │   └── field_config.dart         ← Field config model
│       ├── processors/
│       │   ├── image_processor.dart      ← Image → Text
│       │   └── text_extractor.dart       ← Text → Map<String, dynamic>
│       ├── services/
│       │   └── textreder_service.dart    ← Main public API
│       └── exceptions/
│           └── textreder_exceptions.dart ← Custom exceptions
```

## Step 2: Implementation Files

### File 1: `lib/src/models/extraction_result.dart`

```dart
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
```

### File 2: `lib/src/models/field_config.dart`

```dart
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
```

### File 3: `lib/src/exceptions/textreder_exceptions.dart`

```dart
/// Base exception for Textreder package
class TextrederException implements Exception {
  final String message;
  final dynamic originalError;

  TextrederException(
    this.message, {
    this.originalError,
  });

  @override
  String toString() => 'TextrederException: $message';
}

/// Exception for image processing errors
class ImageProcessingException extends TextrederException {
  ImageProcessingException(
    String message, {
    dynamic originalError,
  }) : super(message, originalError: originalError);

  @override
  String toString() => 'ImageProcessingException: $message';
}

/// Exception for text extraction errors
class ExtractionException extends TextrederException {
  ExtractionException(
    String message, {
    dynamic originalError,
  }) : super(message, originalError: originalError);

  @override
  String toString() => 'ExtractionException: $message';
}

/// Exception for configuration errors
class ConfigurationException extends TextrederException {
  ConfigurationException(
    String message, {
    dynamic originalError,
  }) : super(message, originalError: originalError);

  @override
  String toString() => 'ConfigurationException: $message';
}
```

### File 4: `lib/src/processors/image_processor.dart`

```dart
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import '../exceptions/textreder_exceptions.dart';

/// Processes images and extracts text using ML Kit
class ImageProcessor {
  static final ImageProcessor _instance = ImageProcessor._internal();

  factory ImageProcessor() => _instance;

  ImageProcessor._internal();

  /// Process image file and extract text
  /// Returns raw OCR text
  Future<String> processImage(XFile imageFile) async {
    try {
      if (kDebugMode) {
        debugPrint('🖼️ Processing image: ${imageFile.path}');
      }

      final inputImage = InputImage.fromFilePath(imageFile.path);
      final textRecognizer = TextRecognizer(
        script: TextRecognitionScript.latin,
      );

      final recognizedText = await textRecognizer.processImage(inputImage);

      String extractedText = '';
      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          extractedText += '${line.text}\n';
        }
      }

      await textRecognizer.close();
      await inputImage.close();

      if (kDebugMode) {
        debugPrint('✅ Image processed successfully');
        debugPrint('📝 Extracted text length: ${extractedText.length} chars');
      }

      return extractedText.trim();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Image processing error: $e');
      }
      throw ImageProcessingException(
        'Failed to process image: $e',
        originalError: e,
      );
    }
  }
}
```

### File 5: `lib/src/processors/text_extractor.dart`

```dart
import 'package:flutter/foundation.dart';
import '../models/field_config.dart';
import '../exceptions/textreder_exceptions.dart';

/// Extracts structured data from text using regex patterns
/// Returns Map<String, dynamic> with field IDs as keys
class TextExtractor {
  final List<FieldConfig> fieldConfigs;

  TextExtractor({required this.fieldConfigs});

  /// Extract all fields from raw text
  /// Returns Map<fieldId, extractedValue>
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
```

### File 6: `lib/src/services/textreder_service.dart`

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../models/extraction_result.dart';
import '../models/field_config.dart';
import '../processors/image_processor.dart';
import '../processors/text_extractor.dart';
import '../exceptions/textreder_exceptions.dart';

/// Main public API for Textreder package
/// Handles image processing and data extraction
class TextrederService {
  /// Path to field_config.json
  final String configPath;

  /// Internal state
  late List<FieldConfig> _fieldConfigs;
  late ImageProcessor _imageProcessor;
  late TextExtractor _textExtractor;
  bool _initialized = false;

  TextrederService({
    required this.configPath,
  });

  /// Initialize service - must be called before processing
  Future<void> initialize() async {
    try {
      if (kDebugMode) {
        debugPrint('🚀 Initializing Textreder...');
      }

      // Load config from JSON
      _fieldConfigs = await _loadConfigFromAssets();

      // Initialize processors
      _imageProcessor = ImageProcessor();
      _textExtractor = TextExtractor(fieldConfigs: _fieldConfigs);

      _initialized = true;

      if (kDebugMode) {
        debugPrint('✅ Textreder initialized successfully');
        debugPrint('📋 Loaded ${_fieldConfigs.length} field configurations');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Initialization error: $e');
      }
      throw ConfigurationException(
        'Failed to initialize Textreder: $e',
        originalError: e,
      );
    }
  }

  /// Process image and extract data
  /// Returns ExtractionResult with Map<String, dynamic> containing field IDs as keys
  Future<ExtractionResult> processImage(XFile imageFile) async {
    if (!_initialized) {
      throw TextrederException('Service not initialized. Call initialize() first.');
    }

    try {
      if (kDebugMode) {
        debugPrint('═════════════════════════════════════════════════');
        debugPrint('📸 PROCESSING IMAGE');
        debugPrint('═════════════════════════════════════════════════');
      }

      // Step 1: Process image and extract raw text
      final rawText = await _imageProcessor.processImage(imageFile);

      // Step 2: Extract fields from text (returns Map<String, dynamic>)
      final extractedData = _textExtractor.extractFields(rawText);

      // Step 3: Create and return result
      final result = ExtractionResult(
        data: extractedData,
        rawText: rawText,
        extractedAt: DateTime.now(),
        success: true,
      );

      if (kDebugMode) {
        debugPrint('═════════════════════════════════════════════════');
        debugPrint('✅ EXTRACTION COMPLETE');
        debugPrint('═════════════════════════════════════════════════');
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Processing failed: $e');
      }

      return ExtractionResult(
        data: {},
        rawText: '',
        extractedAt: DateTime.now(),
        success: false,
        errors: [e.toString()],
      );
    }
  }

  /// Extract data from raw text (useful for testing or OCR APIs)
  /// Returns ExtractionResult with Map<String, dynamic> containing field IDs as keys
  ExtractionResult extractFromText(String rawText) {
    if (!_initialized) {
      throw TextrederException('Service not initialized. Call initialize() first.');
    }

    try {
      if (kDebugMode) {
        debugPrint('═════════════════════════════════════════════════');
        debugPrint('📝 EXTRACTING FROM TEXT');
        debugPrint('═════════════════════════════════════════════════');
      }

      // Extract fields from text
      final extractedData = _textExtractor.extractFields(rawText);

      return ExtractionResult(
        data: extractedData,
        rawText: rawText,
        extractedAt: DateTime.now(),
        success: true,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Extraction failed: $e');
      }

      return ExtractionResult(
        data: {},
        rawText: rawText,
        extractedAt: DateTime.now(),
        success: false,
        errors: [e.toString()],
      );
    }
  }

  /// Get all field configurations
  List<FieldConfig> getFieldConfigs() => List.unmodifiable(_fieldConfigs);

  /// Get specific field configuration by ID
  FieldConfig? getFieldConfig(String fieldId) {
    try {
      return _fieldConfigs.firstWhere((f) => f.id == fieldId);
    } catch (e) {
      return null;
    }
  }

  /// Update a field configuration dynamically
  void updateFieldConfig(String fieldId, FieldConfig newConfig) {
    try {
      final index = _fieldConfigs.indexWhere((f) => f.id == fieldId);
      if (index != -1) {
        _fieldConfigs[index] = newConfig;
        // Reinitialize extractor with updated configs
        _textExtractor = TextExtractor(fieldConfigs: _fieldConfigs);

        if (kDebugMode) {
          debugPrint('✅ Field config updated: $fieldId');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error updating field config: $e');
      }
    }
  }

  /// Add new field configuration
  void addFieldConfig(FieldConfig config) {
    _fieldConfigs.add(config);
    _textExtractor = TextExtractor(fieldConfigs: _fieldConfigs);

    if (kDebugMode) {
      debugPrint('✅ Field config added: ${config.id}');
    }
  }

  /// Remove field configuration
  void removeFieldConfig(String fieldId) {
    _fieldConfigs.removeWhere((f) => f.id == fieldId);
    _textExtractor = TextExtractor(fieldConfigs: _fieldConfigs);

    if (kDebugMode) {
      debugPrint('✅ Field config removed: $fieldId');
    }
  }

  /// Load configuration from assets
  Future<List<FieldConfig>> _loadConfigFromAssets() async {
    try {
      final jsonString = await rootBundle.loadString(configPath);
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      final fields = jsonData['fields'] as List;
      return fields
          .map((f) => FieldConfig.fromJson(f as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ConfigurationException(
        'Failed to load field configuration from $configPath: $e',
        originalError: e,
      );
    }
  }

  /// Get debug information
  String getDebugInfo() {
    return '''
╔════════════════════════════════════════════════════════════════╗
║              TEXTREDER DEBUG INFORMATION                       ║
╚════════════════════════════════════════════════════════════════╝

✓ INITIALIZED: $_initialized
📋 FIELD CONFIGS: ${_fieldConfigs.length}
${_fieldConfigs.map((f) => '  • ${f.id} (${f.type})').join('\n')}

📂 CONFIG PATH: $configPath
    ''';
  }
}
```

### File 7: `lib/textreder.dart` (Main Export)

```dart
/// Textreder - Extract structured data from document images
/// 
/// Usage:
/// ```dart
/// final service = TextrederService(
///   configPath: 'assets/field_config.json',
/// );
/// await service.initialize();
/// 
/// final result = await service.processImage(imageFile);
/// print(result.data); // Map<String, dynamic> with field IDs as keys
/// ```

export 'src/services/textreder_service.dart';
export 'src/models/extraction_result.dart';
export 'src/models/field_config.dart';
export 'src/processors/image_processor.dart';
export 'src/processors/text_extractor.dart';
export 'src/exceptions/textreder_exceptions.dart';
```

---

## Step 3: Usage in Your App

### How to Use the Package

```dart
import 'package:textreder/textreder.dart';

class OcrController extends GetxController {
  final textrederService = TextrederService(
    configPath: 'assets/field_config.json',
  );

  @override
  void onInit() async {
    super.onInit();
    await textrederService.initialize();
  }

  Future<void> processImage() async {
    final imageFile = /* get image */;
    
    // Process image - returns ExtractionResult
    final result = await textrederService.processImage(imageFile);
    
    if (result.success) {
      // result.data is Map<String, dynamic>
      // Keys are field IDs from field_config.json
      print(result.data);
      // Output:
      // {
      //   'name': 'John Doe',
      //   'phone': 'MM19779347',
      //   'email': 'john@example.com',
      //   'age': 28
      // }
      
      // Access specific fields by ID
      final name = result.data['name'];
      final phone = result.data['phone'];
    } else {
      print('Errors: ${result.errors}');
    }
  }
}
```

---

## Data Flow Summary

```
┌──────────────────────────────────┐
│   Your Flutter App               │
│   (OcrController)                │
└────────────┬─────────────────────┘
             │
             │ imageFile
             ▼
┌──────────────────────────────────┐
│   TextrederService (PUBLIC API)  │
│   - processImage()               │
│   - extractFromText()            │
└────────────┬─────────────────────┘
             │
    ┌────────┴────────┐
    │                 │
    ▼                 ▼
┌──────────────┐  ┌─────────────────┐
│ImageProcessor│  │ TextExtractor   │
│              │  │                 │
│processImage()│  │extractFields()  │
└──────┬───────┘  └────────┬────────┘
       │                   │
       │                   │
       ▼                   │
    [Image]                │
       │                   │
   (ML Kit)                │
       │                   │
       ▼                   │
    [Raw Text] ───────────┬─────────►
                          │
                      (Regex)
                          │
                          ▼
                ┌──────────────────────┐
                │ Map<String, dynamic> │
                │                      │
                │ 'name': 'John Doe'   │
                │ 'phone': 'MM...'     │
                │ 'email': 'john@...'  │
                │ 'age': 28            │
                └──────────────────────┘
                          │
                          ▼
                ┌──────────────────────┐
                │ ExtractionResult     │
                │ - data (the Map)     │
                │ - rawText            │
                │ - extractedAt        │
                │ - success            │
                │ - errors             │
                └──────────────────────┘
                          │
                          ▼
                ┌──────────────────────┐
                │  Your App Gets Data  │
                │  result.data['name'] │
                │  result.data['phone']│
                │  etc...              │
                └──────────────────────┘
```

---

## Key Points

✅ **ImageProcessor** - Image to Text  
✅ **TextExtractor** - Text to Map<String, dynamic>  
✅ **TextrederService** - Public API (combines both)  
✅ **ExtractionResult** - Clean return model  
✅ **Map<String, dynamic>** - Field IDs as keys  
✅ **field_config.json** - Drives everything  

---

Ready to convert? Should I now create these files in your project?
