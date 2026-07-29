# 📦 Creating TextReder as a Reusable Package

## Overview

Converting TextReder into a package allows you to:
- ✅ Reuse in multiple projects
- ✅ Simple public API (clean separation)
- ✅ Configurable field extraction
- ✅ Return structured `Map<String, dynamic>` with field IDs as keys
- ✅ Handle both image processing and data extraction

---

## Package Architecture

### Public API Structure

```
textreder_package/
├── lib/
│   ├── textreder.dart              (main export file)
│   └── src/
│       ├── models/
│       │   ├── field_config.dart    (FieldConfig class)
│       │   └── extraction_result.dart (Result model)
│       ├── processors/
│       │   ├── image_processor.dart (ImageProcessor class)
│       │   └── text_extractor.dart  (TextExtractor class)
│       ├── services/
│       │   └── textreder_service.dart (Main service - public API)
│       └── exceptions/
│           └── textreder_exceptions.dart
├── assets/
│   └── field_config.json            (default config)
├── pubspec.yaml
└── README.md
```

---

## How It Would Work

### 1️⃣ **User Configures Fields** (field_config.json)

```json
{
  "version": "2.0",
  "fields": [
    {
      "id": "name",
      "content_name": "name||Name",
      "type": "String",
      "regex": "(?:name|Name)\\s*:?\\s*([a-zA-Z\\s]+?)(?=\\n|$)",
      "caseSensitive": false
    },
    {
      "id": "phone",
      "content_name": "phone||Phone||Number",
      "type": "String",
      "regex": "(?:phone|Phone)\\s*:?\\s*([a-zA-Z0-9\\+\\s\\(\\)\\-]+?)(?=\\n|$)",
      "caseSensitive": false
    }
  ]
}
```

### 2️⃣ **User Processes Image**

```dart
import 'package:textreder/textreder.dart';

final service = TextrederService(
  configPath: 'assets/field_config.json',  // Your config
);

await service.initialize();

// Process image
final result = await service.processImage(imageFile);

// Get extracted data as Map<String, dynamic>
final data = result.data;  // {'name': 'John Doe', 'phone': 'MM19779347', ...}
```

### 3️⃣ **Output Format**

```dart
// Result contains:
result.data;           // Map<String, dynamic> {'id': value, ...}
result.rawText;        // String - original OCR text
result.extractedAt;    // DateTime - when extraction happened
result.success;        // bool - whether extraction was successful
result.errors;         // List<String> - any errors encountered
```

---

## Complete Package Implementation

### **Model: ExtractionResult**

```dart
class ExtractionResult {
  final Map<String, dynamic> data;  // <-- KEY IDs map
  final String rawText;
  final DateTime extractedAt;
  final bool success;
  final List<String> errors;

  ExtractionResult({
    required this.data,
    required this.rawText,
    required this.extractedAt,
    this.success = true,
    this.errors = const [],
  });

  // Convert to JSON
  Map<String, dynamic> toJson() => {
    'data': data,
    'rawText': rawText,
    'extractedAt': extractedAt.toIso8601String(),
    'success': success,
  };
}
```

### **Class: ImageProcessor**

```dart
class ImageProcessor {
  static final ImageProcessor _instance = ImageProcessor._internal();

  factory ImageProcessor() => _instance;
  ImageProcessor._internal();

  /// Process image and extract text
  Future<String> processImage(XFile imageFile) async {
    try {
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      
      final recognizedText = await textRecognizer.processImage(inputImage);
      
      String extractedText = '';
      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          extractedText += '${line.text}\n';
        }
      }
      
      await textRecognizer.close();
      await inputImage.close();
      
      return extractedText;
    } catch (e) {
      throw TextrederException('Failed to process image: $e');
    }
  }
}
```

### **Class: TextExtractor**

```dart
class TextExtractor {
  final List<FieldConfig> fieldConfigs;

  TextExtractor({required this.fieldConfigs});

  /// Extract all fields from raw text
  /// Returns Map<String, dynamic> with field IDs as keys
  Map<String, dynamic> extractFields(String rawText) {
    final extracted = <String, dynamic>{};

    for (final fieldConfig in fieldConfigs) {
      try {
        final value = _extractField(rawText, fieldConfig);
        if (value != null) {
          extracted[fieldConfig.id] = _convertType(value, fieldConfig.type);
        }
      } catch (e) {
        // Log error but continue with other fields
        debugPrint('Error extracting ${fieldConfig.id}: $e');
      }
    }

    return extracted;
  }

  // Extract single field
  String? _extractField(String text, FieldConfig config) {
    try {
      final pattern = RegExp(config.regex, 
        caseSensitive: config.caseSensitive,
        multiLine: true,
        dotAll: true,
      );
      
      final match = pattern.firstMatch(text);
      if (match != null && match.groupCount > 0) {
        return match.group(1)?.trim();
      }
    } catch (e) {
      debugPrint('Regex error for ${config.id}: $e');
    }
    return null;
  }

  // Convert to proper type
  dynamic _convertType(String value, String type) {
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
        return value;
    }
  }
}
```

### **Main Service Class: TextrederService**

```dart
class TextrederService {
  final String configPath;
  late List<FieldConfig> _fieldConfigs;
  late ImageProcessor _imageProcessor;
  late TextExtractor _textExtractor;

  TextrederService({
    required this.configPath,
  });

  /// Initialize the service
  Future<void> initialize() async {
    try {
      // Load config from JSON
      _fieldConfigs = await _loadConfig();
      
      // Initialize processors
      _imageProcessor = ImageProcessor();
      _textExtractor = TextExtractor(fieldConfigs: _fieldConfigs);
    } catch (e) {
      throw TextrederException('Failed to initialize: $e');
    }
  }

  /// Process image and extract data
  /// Returns ExtractionResult with Map<String, dynamic> as data
  Future<ExtractionResult> processImage(XFile imageFile) async {
    try {
      // Step 1: Process image and extract text
      final rawText = await _imageProcessor.processImage(imageFile);
      
      // Step 2: Extract fields (returns Map<String, dynamic>)
      final extractedData = _textExtractor.extractFields(rawText);
      
      // Step 3: Return result
      return ExtractionResult(
        data: extractedData,  // <-- Map with field IDs as keys!
        rawText: rawText,
        extractedAt: DateTime.now(),
        success: true,
      );
    } catch (e) {
      return ExtractionResult(
        data: {},
        rawText: '',
        extractedAt: DateTime.now(),
        success: false,
        errors: [e.toString()],
      );
    }
  }

  /// Process raw text (for testing/OCR APIs)
  ExtractionResult extractFromText(String rawText) {
    try {
      final extractedData = _textExtractor.extractFields(rawText);
      
      return ExtractionResult(
        data: extractedData,  // <-- Map with field IDs as keys!
        rawText: rawText,
        extractedAt: DateTime.now(),
        success: true,
      );
    } catch (e) {
      return ExtractionResult(
        data: {},
        rawText: rawText,
        extractedAt: DateTime.now(),
        success: false,
        errors: [e.toString()],
      );
    }
  }

  /// Load field config from JSON
  Future<List<FieldConfig>> _loadConfig() async {
    final String jsonString = 
        await rootBundle.loadString(configPath);
    final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
    
    final fields = jsonData['fields'] as List;
    return fields
        .map((f) => FieldConfig.fromJson(f as Map<String, dynamic>))
        .toList();
  }

  /// Get available field configurations
  List<FieldConfig> getFieldConfigs() => _fieldConfigs;

  /// Update field configuration
  void updateFieldConfig(String fieldId, FieldConfig config) {
    final index = _fieldConfigs.indexWhere((f) => f.id == fieldId);
    if (index != -1) {
      _fieldConfigs[index] = config;
      _textExtractor = TextExtractor(fieldConfigs: _fieldConfigs);
    }
  }
}
```

---

## Usage Example

### **Simple Usage in Your App**

```dart
import 'package:textreder/textreder.dart';

class MyOcrPage extends StatefulWidget {
  @override
  State<MyOcrPage> createState() => _MyOcrPageState();
}

class _MyOcrPageState extends State<MyOcrPage> {
  late TextrederService _textreder;

  @override
  void initState() {
    super.initState();
    _initializeTextreder();
  }

  Future<void> _initializeTextreder() async {
    _textreder = TextrederService(
      configPath: 'assets/field_config.json',
    );
    await _textreder.initialize();
  }

  Future<void> _captureAndProcess() async {
    final picker = ImagePicker();
    final imageFile = await picker.pickImage(source: ImageSource.camera);
    
    if (imageFile != null) {
      // Process image
      final result = await _textreder.processImage(imageFile);
      
      if (result.success) {
        // Get data as Map<String, dynamic>
        // Keys are field IDs from field_config.json
        print('Extracted Data: ${result.data}');
        
        // Access specific fields by ID
        final name = result.data['name'];       // 'John Doe'
        final phone = result.data['phone'];     // 'MM19779347'
        final email = result.data['email'];     // 'john@example.com'
        
        // Use data in your app
        _populateForm(result.data);
      } else {
        print('Extraction failed: ${result.errors}');
      }
    }
  }

  void _populateForm(Map<String, dynamic> data) {
    // Dynamically populate based on extracted data
    data.forEach((id, value) {
      if (formControllers.containsKey(id)) {
        formControllers[id].text = value?.toString() ?? '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _captureAndProcess,
            child: Text('Capture & Extract'),
          ),
        ],
      ),
    );
  }
}
```

---

## Advanced Usage

### **Use with Different Config**

```dart
// Use default config
var service = TextrederService(configPath: 'assets/field_config.json');

// Or use custom config
var customService = TextrederService(
  configPath: 'assets/custom_config.json',
);

await customService.initialize();
```

### **Process Text Only (No Image)**

```dart
// For testing or OCR API integration
final rawOcrText = '''
Name: John Doe
Phone: MM19779347
Email: john@example.com
''';

final result = _textreder.extractFromText(rawOcrText);
print(result.data);  // {'name': 'John Doe', 'phone': 'MM19779347', ...}
```

### **Modify Field Config Dynamically**

```dart
// Add new field at runtime
final newField = FieldConfig(
  id: 'department',
  contentName: 'department||dept',
  type: 'String',
  regex: '(?:department|dept)\\s*:?\\s*([a-zA-Z\\s]+?)(?=\\n|$)',
  caseSensitive: false,
);

service.updateFieldConfig('department', newField);

// Re-process with new config
final result = await service.processImage(imageFile);
// Now includes 'department' in result.data
```

---

## Package Structure (pubspec.yaml)

```yaml
name: textreder
description: >
  A Flutter package for extracting structured data from document images
  using OCR and regex-based field extraction with configurable JSON schema.

version: 1.0.0
publish_to: none

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: '>=3.0.0'

dependencies:
  flutter:
    sdk: flutter
  google_mlkit_text_recognition: ^0.15.0
  image_picker: ^1.2.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

flutter:
  assets:
    - assets/field_config.json
```

---

## Benefits of Package Approach

| Aspect | Benefit |
|--------|---------|
| **Reusability** | Use in multiple Flutter projects |
| **Clean API** | Single service class with simple methods |
| **Configurable** | Change behavior via JSON (no code changes) |
| **Type-Safe** | Explicit return types (ExtractionResult) |
| **Maintainable** | Separated concerns (ImageProcessor, TextExtractor) |
| **Testable** | Easy to unit test each component |
| **Extensible** | Easy to add new field types or processors |

---

## Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                   Your Flutter App                           │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
                ┌────────────────────┐
                │ TextrederService   │  (Public API)
                │  - initialize()    │
                │  - processImage()  │
                │  - extractFromText()
                └────────┬───────────┘
                         │
          ┌──────────────┴──────────────┐
          │                             │
          ▼                             ▼
    ┌──────────────┐          ┌──────────────────┐
    │ImageProcessor│          │ TextExtractor    │
    │              │          │  - extractFields()
    │- processImage│          │  - convertType() │
    └────┬─────────┘          └────────┬─────────┘
         │                            │
         │                            │
         ▼                            ▼
      [Image] ─ OCR ──>  [Raw Text]  ──> Regex  ──>  [Extracted Data]
                                         ↑
                                         └─ field_config.json
                                         
OUTPUT: Map<String, dynamic>
{
  'name': 'John Doe',
  'phone': 'MM19779347',
  'email': 'john@example.com',
  ...
}
```

---

## Publishing to pub.dev (Optional)

Once ready, publish to pub.dev:

```bash
flutter pub publish
```

Then anyone can use it:

```yaml
# In their pubspec.yaml
dependencies:
  textreder: ^1.0.0
```

---

## Summary: YES, This is Completely Possible! ✅

✅ **ImageProcessor Class** - Handles image → text extraction  
✅ **TextExtractor Class** - Handles text → structured data  
✅ **TextrederService** - Main API combining both  
✅ **ExtractionResult** - Clean return model  
✅ **Map<String, dynamic>** - Field IDs as keys  
✅ **Configurable via JSON** - No code changes needed  
✅ **Reusable Package** - Use in any Flutter project  

**Next Steps:**
1. Extract code from current app into package structure
2. Create clean public API (TextrederService)
3. Test with multiple projects
4. Document thoroughly
5. Publish to pub.dev (optional)

---

**Would you like me to:**
1. Convert the current project into this package structure?
2. Create the complete package skeleton?
3. Show how to integrate it back into your current app?
