# 📦 TextReder Package - Quick Reference

## What You Get

A **professional, reusable Flutter package** that:
- ✅ Processes images and extracts text (OCR)
- ✅ Returns structured data as `Map<String, dynamic>`
- ✅ Uses field IDs from `field_config.json` as map keys
- ✅ Handles type conversion automatically
- ✅ Works in any Flutter project

---

## 🚀 Quick Start (30 seconds)

### 1. Initialize Service
```dart
final service = TextrederService(
  configPath: 'assets/field_config.json',
);
await service.initialize();
```

### 2. Process Image
```dart
final result = await service.processImage(imageFile);
```

### 3. Get Data
```dart
if (result.success) {
  print(result.data);
  // {'name': 'John Doe', 'phone': 'MM19779347', 'age': 28}
}
```

---

## 📊 Simple Example

```dart
// Initialize once
final textreder = TextrederService(
  configPath: 'assets/field_config.json',
);
await textreder.initialize();

// Use it
final result = await textreder.processImage(imageFile);

// Access extracted data
final name = result.data['name'];      // String
final phone = result.data['phone'];    // String  
final age = result.data['age'];        // int (auto-converted)
```

---

## 🔑 Key Classes

| Class | Purpose |
|-------|---------|
| **TextrederService** | Main API - initialize, process images, manage configs |
| **ExtractionResult** | Result model - contains `data`, `rawText`, `success`, `errors` |
| **FieldConfig** | Field definition - `id`, `content_name`, `type`, `regex` |
| **ImageProcessor** | (Internal) Converts images to text via ML Kit |
| **TextExtractor** | (Internal) Converts text to `Map<String, dynamic>` |

---

## 📋 Configuration (field_config.json)

```json
{
  "fields": [
    {
      "id": "name",                    // ← Map key
      "content_name": "name||Name",
      "type": "String",
      "regex": "...",
      "caseSensitive": false
    },
    {
      "id": "age",                     // ← Map key  
      "content_name": "age||Age",
      "type": "int",                   // ← Auto-converted
      "regex": "...",
      "caseSensitive": false
    }
  ]
}
```

### Result Map:
```dart
{
  'name': 'John Doe',     // String
  'age': 28               // int (auto-converted from "28")
}
```

---

## ✨ Features

```dart
// Initialize
await service.initialize();

// Process images
final result = await service.processImage(imageFile);

// Process raw text (for testing)
final result = service.extractFromText(rawText);

// Manage field configs
service.getFieldConfigs();
service.addFieldConfig(config);
service.updateFieldConfig('name', newConfig);
service.removeFieldConfig('name');
```

---

## 🎯 Return Model (ExtractionResult)

```dart
class ExtractionResult {
  Map<String, dynamic> data;      // ← The extracted data!
  String rawText;                 // ← Original OCR text
  DateTime extractedAt;           // ← When extracted
  bool success;                   // ← Whether it worked
  List<String> errors;            // ← Any errors that occurred
  
  String prettyPrint();           // ← Pretty formatted output
}
```

---

## 💡 Type Support

Auto-converts extracted values:

| Type | Example |
|------|---------|
| **String** | `"John Doe"` |
| **int** | `28` |
| **double** | `3.14` |
| **bool** | `true` |
| **DateTime** | `2026-07-29` |

---

## 📱 Real World Usage

```dart
class OcrPage extends StatefulWidget {
  @override
  State<OcrPage> createState() => _OcrPageState();
}

class _OcrPageState extends State<OcrPage> {
  late TextrederService _textreder;
  Map<String, dynamic>? _extractedData;

  @override
  void initState() {
    super.initState();
    _initTextreder();
  }

  Future<void> _initTextreder() async {
    _textreder = TextrederService(
      configPath: 'assets/field_config.json',
    );
    await _textreder.initialize();
  }

  Future<void> _scanDocument() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    
    if (image != null) {
      final result = await _textreder.processImage(image);
      
      if (result.success) {
        setState(() => _extractedData = result.data);
        
        // Use the data
        print('Name: ${result.data['name']}');
        print('Phone: ${result.data['phone']}');
        print('Email: ${result.data['email']}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Document Scanner')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _scanDocument,
            child: Text('Scan Document'),
          ),
          if (_extractedData != null)
            Expanded(
              child: ListView.builder(
                itemCount: _extractedData!.length,
                itemBuilder: (ctx, idx) {
                  final entry = _extractedData!.entries.toList()[idx];
                  return ListTile(
                    title: Text(entry.key),
                    subtitle: Text(entry.value.toString()),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
```

---

## 🔧 Error Handling

```dart
try {
  final result = await service.processImage(imageFile);
  
  if (!result.success) {
    print('Errors: ${result.errors}');
  }
} on TextrederException catch (e) {
  print('Textreder error: ${e.message}');
} on ImageProcessingException catch (e) {
  print('Image error: ${e.message}');
} on ExtractionException catch (e) {
  print('Extraction error: ${e.message}');
} on ConfigurationException catch (e) {
  print('Config error: ${e.message}');
}
```

---

## 📦 File Structure

```
lib/
├── textreder.dart                     (← Export file)
└── src/
    ├── models/
    │   ├── extraction_result.dart
    │   └── field_config.dart
    ├── processors/
    │   ├── image_processor.dart
    │   └── text_extractor.dart
    ├── services/
    │   └── textreder_service.dart
    └── exceptions/
        └── textreder_exceptions.dart
```

---

## 🚀 Advanced Usage

### Extract from Raw Text (Testing)
```dart
final rawText = '''
Name: John Doe
Age: 28
Email: john@example.com
''';

final result = service.extractFromText(rawText);
print(result.data);  // {'name': 'John Doe', 'age': 28, ...}
```

### Modify Field Config at Runtime
```dart
final newField = FieldConfig(
  id: 'department',
  contentName: 'department||dept',
  type: 'String',
  regex: '...',
);

service.addFieldConfig(newField);

// Re-process and new field will be included
final result = await service.processImage(imageFile);
```

### Get Debug Info
```dart
print(service.getDebugInfo());
// Shows initialized state, loaded fields, config path, etc.
```

---

## ✅ Why This Package is Great

| Aspect | Benefit |
|--------|---------|
| **Reusable** | Use in any Flutter project |
| **Clean** | Single simple API |
| **Configurable** | JSON-driven, no code changes needed |
| **Type-Safe** | Explicit models and return types |
| **Extensible** | Easy to add new field types |
| **Testable** | Separated concerns |
| **Production-Ready** | Zero errors, well-structured |
| **Shareable** | Can publish to pub.dev |

---

## 📝 Summary

**TextReder is a professional, reusable Flutter package** that makes OCR document extraction simple:

1. **Configure fields** in `field_config.json`
2. **Process images** with `TextrederService`
3. **Get structured data** as `Map<String, dynamic>`
4. **Use field IDs as keys** for clean access

**That's it!** 🎉

---

**For Complete Documentation:**
- `PACKAGE_IMPLEMENTATION_GUIDE.md` - Full implementation details
- `PACKAGE_ARCHITECTURE_GUIDE.md` - Architecture explanation
- `PACKAGE_CONVERSION_COMPLETE.md` - Migration summary

**Current Status**: ✅ Production Ready  
**Version**: 2.0 (Package Edition)  
**Date**: 2026-07-29
