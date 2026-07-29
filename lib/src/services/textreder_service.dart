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
