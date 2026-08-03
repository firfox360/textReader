# TextReder - OCR Document Extraction Package

[![Pub](https://img.shields.io/pub/v/textreder)](https://pub.dev/packages/textreder)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![style: flutter_lints](https://img.shields.io/badge/style-flutter__lints-40c4ff.svg)](https://pub.dev/packages/flutter_lints)

A powerful Flutter package for extracting structured data from document images using OCR and regex-based field extraction.

**Features:**
- 📸 **Image Processing** - Convert images to text using Google ML Kit
- 🎯 **Structured Extraction** - Extract fields based on JSON configuration
- 🔄 **Type Conversion** - Automatic type conversion (String, int, double, bool, DateTime)
- ⚙️ **Configuration-Driven** - No code changes needed, just update JSON
- 📊 **Clean API** - Simple `TextrederService` with intuitive methods
- 🗺️ **Map Output** - Results as `Map<String, dynamic>` with field IDs as keys

## Installation

Add `textreder` to your `pubspec.yaml`:

```yaml
dependencies:
  textreder: ^1.0.0
```

Then run:
```bash
flutter pub get
```

## Quick Start

### 1. Configure Fields

Create `assets/field_config.json`:

```json
{
  "version": "2.0",
  "fields": [
    {
      "id": "name",
      "content_name": "name||Name||full_name",
      "type": "String",
      "regex": "(?:name|Name)\\s*:?\\s*([a-zA-Z\\s]+?)(?=\\n|$)",
      "caseSensitive": false
    },
    {
      "id": "phone",
      "content_name": "phone||Phone||number||Number",
      "type": "String",
      "regex": "(?:phone|Phone)\\s*:?\\s*([a-zA-Z0-9\\+\\s\\(\\)\\-\\.]+?)(?=\\n|$)",
      "caseSensitive": false
    },
    {
      "id": "age",
      "content_name": "age||Age",
      "type": "int",
      "regex": "(?:age|Age)\\s*:?\\s*(\\d+)",
      "caseSensitive": false
    }
  ]
}
```

### 2. Update pubspec.yaml

```yaml
flutter:
  assets:
    - assets/field_config.json
```

### 3. Use in Your Code

```dart
import 'package:textreder/textreder.dart';
import 'package:image_picker/image_picker.dart';

// Initialize service
final service = TextrederService(
  configPath: 'assets/field_config.json',
);
await service.initialize();

// Process image
final imageFile = await ImagePicker().pickImage(source: ImageSource.camera);
final result = await service.processImage(imageFile!);

// Access extracted data
if (result.success) {
  print(result.data);  // Map<String, dynamic>
  // Output: {'name': 'John Doe', 'phone': 'MM19779347', 'age': 28}
  
  // Access specific fields
  final name = result.data['name'];      // String
  final phone = result.data['phone'];    // String
  final age = result.data['age'];        // int (auto-converted)
}
```

## API Reference

### TextrederService

Main service class for OCR and data extraction.

#### Methods

**`initialize()`**
```dart
Future<void> initialize()
```
Initializes the service and loads field configuration from JSON.

**`processImage(XFile imageFile)`**
```dart
Future<ExtractionResult> processImage(XFile imageFile)
```
Processes an image file and extracts structured data.

**`extractFromText(String rawText)`**
```dart
ExtractionResult extractFromText(String rawText)
```
Extracts data from raw text (useful for testing or OCR APIs).

**`getFieldConfigs()`**
```dart
List<FieldConfig> getFieldConfigs()
```
Returns all field configurations.

**`getFieldConfig(String fieldId)`**
```dart
FieldConfig? getFieldConfig(String fieldId)
```
Returns a specific field configuration by ID.

**`addFieldConfig(FieldConfig config)`**
```dart
void addFieldConfig(FieldConfig config)
```
Adds a new field configuration dynamically.

**`updateFieldConfig(String fieldId, FieldConfig config)`**
```dart
void updateFieldConfig(String fieldId, FieldConfig config)
```
Updates an existing field configuration.

**`removeFieldConfig(String fieldId)`**
```dart
void removeFieldConfig(String fieldId)
```
Removes a field configuration.

### ExtractionResult

Result model containing extracted data and metadata.

```dart
class ExtractionResult {
  /// Extracted data: Map<fieldId, value>
  Map<String, dynamic> data;
  
  /// Original OCR text
  String rawText;
  
  /// When extraction happened
  DateTime extractedAt;
  
  /// Whether extraction was successful
  bool success;
  
  /// Any errors that occurred
  List<String> errors;
  
  /// Pretty formatted output
  String prettyPrint();
}
```

### FieldConfig

Configuration for a single field.

```dart
class FieldConfig {
  /// Unique field identifier (used as key in result Map)
  String id;
  
  /// Names to look for (pipe-separated): "name||Name||full_name"
  String contentName;
  
  /// Data type: "String", "int", "double", "bool", "DateTime"
  String type;
  
  /// Regex pattern for extraction
  String regex;
  
  /// Case sensitivity for regex
  bool caseSensitive;
}
```

## Configuration Format

### field_config.json

```json
{
  "version": "2.0",
  "fields": [
    {
      "id": "fieldName",                    // Used as key in Map
      "content_name": "label||alt_label",   // Pipe-separated alternatives
      "type": "String|int|double|bool|DateTime",  // Data type
      "regex": "regex_pattern",             // Extraction pattern
      "caseSensitive": false|true           // Case sensitivity
    }
  ]
}
```

### Field Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | String | Unique identifier, used as Map key in results |
| `content_name` | String | Pipe-separated names to match in raw text |
| `type` | String | Data type for automatic conversion |
| `regex` | String | Regex pattern for value extraction |
| `caseSensitive` | bool | Whether regex is case-sensitive |

### Supported Types

| Type | Conversion | Example |
|------|-----------|---------|
| String | No conversion | `"John Doe"` |
| int | `int.parse()` | `28` |
| double | `double.parse()` | `3.14` |
| bool | `"true"` → `true` | `true` |
| DateTime | `DateTime.parse()` | `2026-07-29` |

## Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:textreder/textreder.dart';

class DocumentScannerPage extends StatefulWidget {
  @override
  State<DocumentScannerPage> createState() => _DocumentScannerPageState();
}

class _DocumentScannerPageState extends State<DocumentScannerPage> {
  late TextrederService _textreder;
  ExtractionResult? _result;
  bool _loading = false;

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

  Future<void> _scanDocument() async {
    setState(() => _loading = true);
    
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    
    if (image != null) {
      final result = await _textreder.processImage(image);
      setState(() {
        _result = result;
        _loading = false;
      });

      if (!result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${result.errors.join(', ')}')),
        );
      }
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Document Scanner')),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(16),
              children: [
                ElevatedButton.icon(
                  onPressed: _scanDocument,
                  icon: Icon(Icons.camera),
                  label: Text('Scan Document'),
                ),
                if (_result != null) ...[
                  SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Extracted Data',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          SizedBox(height: 16),
                          ..._result!.data.entries.map((e) => Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(e.key, style: TextStyle(fontWeight: FontWeight.bold)),
                                Text(e.value.toString()),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
```

## Error Handling

```dart
try {
  final result = await service.processImage(imageFile);
  
  if (!result.success) {
    print('Extraction failed: ${result.errors}');
  }
} on TextrederException catch (e) {
  print('Textreder error: ${e.message}');
} on ImageProcessingException catch (e) {
  print('Image processing error: ${e.message}');
} on ExtractionException catch (e) {
  print('Extraction error: ${e.message}');
} on ConfigurationException catch (e) {
  print('Configuration error: ${e.message}');
}
```

## Advanced Usage

### Extract from Raw Text (Testing)

```dart
final rawText = '''
Name: John Doe
Phone: MM19779347
Age: 28
''';

final result = service.extractFromText(rawText);
print(result.data);  // {'name': 'John Doe', 'phone': 'MM19779347', 'age': 28}
```

### Dynamic Field Management

```dart
// Add a new field
final departmentField = FieldConfig(
  id: 'department',
  contentName: 'department||dept',
  type: 'String',
  regex: '(?:department|dept)\\s*:?\\s*([a-zA-Z\\s]+?)(?=\\n|$)',
);
service.addFieldConfig(departmentField);

// Update existing field
service.updateFieldConfig('phone', updatedPhoneConfig);

// Remove field
service.removeFieldConfig('age');
```

## Architecture

TextReder follows a clean architecture with separated concerns:

- **ImageProcessor** - Handles image to text conversion
- **TextExtractor** - Handles text to structured data extraction  
- **TextrederService** - Public API combining both
- **FieldConfig** - Configuration model
- **ExtractionResult** - Return model

## Permissions

The package requires the following permissions:

### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to scan documents</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to select images</string>
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - see LICENSE file for details.

## Support

For issues, feature requests, or questions, please visit:
- [GitHub Issues](https://github.com/yourusername/textreder/issues)
- [GitHub Discussions](https://github.com/yourusername/textreder/discussions)

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for release history.
