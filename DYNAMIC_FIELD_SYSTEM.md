# 🔄 Dynamic Field System - New Flow Documentation

## Overview

The Textreder app now uses a **dynamic field system** where:
- ✅ UI is built **statically by the user**
- ✅ Fields are configured in **field_config.json** (minimal config)
- ✅ Extraction adapts **automatically** to the configured fields
- ✅ Add/modify fields in JSON → Extraction automatically updates

---

## 📋 New Architecture

### Old Flow (Static) ❌
```
Hard-coded ExtractedData class
    ↓
Fixed 8 fields (name, age, gender, etc.)
    ↓
UI built around these specific fields
    ↓
Hard to extend or modify
```

### New Flow (Dynamic) ✅
```
field_config.json (user configures fields)
    ↓
DynamicFieldService (reads config)
    ↓
Extraction auto-adjusts to configured fields
    ↓
DynamicExtractedData (flexible data model)
    ↓
User builds UI with TextEditingControllers manually
    ↓
Easy to add/remove/modify fields
```

---

## 🎯 Step-by-Step Usage

### 1. Configure Fields in `field_config.json`

The **minimal** field configuration now only needs:

```json
{
  "version": "2.0",
  "fields": [
    {
      "id": "name",
      "content_name": "name||Name||nombre",      // Names it looks for in raw text
      "type": "String",                           // Data type
      "regex": "(?:name|full name...)...",       // Pattern to extract
      "caseSensitive": false
    },
    {
      "id": "age",
      "content_name": "age||Age||edad",
      "type": "int",
      "regex": "(?:age|edad)\\s*:?\\s*(\\d+)",
      "caseSensitive": false
    },
    {
      "id": "phone",
      "content_name": "phone||Phone||number||Number",
      "type": "String",
      "regex": "(?:phone|...|number|número)\\s*:?\\s*([a-zA-Z0-9...]+)",
      "caseSensitive": false
    }
  ]
}
```

**Key Points:**
- `content_name`: Pipe-separated (||) list of names to look for
- `type`: The data type - "String", "int", "double", "bool", "DateTime"
- `regex`: Extraction pattern (kept from before)
- `caseSensitive`: Whether regex is case-sensitive

### 2. Initialize in Your Code

```dart
// In your controller or service
final dynamicFieldService = DynamicFieldService();
await dynamicFieldService.initialize(); // Load from field_config.json
```

### 3. Extract Data Dynamically

```dart
// Extract all fields configured in field_config.json
final extractedFields = dynamicFieldService.extractAllFields(rawText);

// Create dynamic extracted data
final extractedData = DynamicExtractedData.fromExtractedFields(
  extractedFields,
  rawText: rawText,
);

// Get field count (based on config)
print('Extracted ${extractedData.getFieldCount()} fields');
```

### 4. Build UI Statically (Your Choice)

```dart
// You create the UI with only the fields YOU need
return Column(
  children: [
    TextField(
      controller: formControllers['name'],
      decoration: InputDecoration(labelText: 'Name'),
    ),
    TextField(
      controller: formControllers['email'],
      decoration: InputDecoration(labelText: 'Email'),
    ),
    // Add more fields as needed
  ],
);
```

### 5. Populate Form Fields

```dart
// Populate only the fields you created
controller.populateFormFields(['name', 'email', 'phone']);

// Or manually
final nameValue = controller.getFieldValue('name');
formControllers['name'].text = nameValue?.toString() ?? '';
```

---

## 🔧 Working with Dynamic Data

### Get Field Value

```dart
final nameValue = dynamicExtractedData.getField('name');
print(nameValue); // "John Doe"
```

### Set Field Value

```dart
extractedData.setField('name', 'Jane Doe');
```

### Check if Field Exists

```dart
if (extractedData.hasField('phone')) {
  print('Phone field found');
}
```

### Get All Fields

```dart
final allFields = extractedData.getAllFields();
// Returns: {'name': 'John', 'age': 28, 'phone': 'MM19779347', ...}
```

### Convert to JSON

```dart
// As string
final json = extractedData.toJsonString();
// {"name":"John Doe","age":28,"phone":"MM19779347",...}

// As map
final jsonMap = extractedData.toJson();
```

---

## ➕ Adding New Fields

### Method 1: Edit field_config.json

```json
{
  "id": "department",
  "content_name": "department||Department||dept",
  "type": "String",
  "regex": "(?:department|dept)\\s*:?\\s*([a-zA-Z\\s]+?)(?=\\n|$)",
  "caseSensitive": false
}
```

**That's it!** Extraction automatically picks it up.

### Method 2: Add Programmatically

```dart
final newField = DynamicFieldConfig(
  id: 'department',
  contentName: 'department||Department',
  type: 'String',
  regex: '(?:department|dept)\\s*:?\\s*([a-zA-Z\\s]+?)(?=\\n|$)',
  caseSensitive: false,
);

dynamicFieldService.addField(newField);
```

### Method 3: Update Existing Field

```dart
final updatedField = DynamicFieldConfig(
  id: 'phone',
  contentName: 'phone||Phone||number||mobile',
  type: 'String',
  regex: 'new_regex_pattern',
  caseSensitive: false,
);

dynamicFieldService.updateField('phone', updatedField);
```

---

## 🎨 Complete Example

### field_config.json

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
      "id": "email",
      "content_name": "email||Email",
      "type": "String",
      "regex": "(?:email|Email)\\s*:?\\s*([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,})",
      "caseSensitive": false
    },
    {
      "id": "phone",
      "content_name": "phone||Phone||Number",
      "type": "String",
      "regex": "(?:phone|Phone|Number)\\s*:?\\s*([a-zA-Z0-9\\+\\s\\(\\)\\-\\.]+?)(?=\\n|$)",
      "caseSensitive": false
    }
  ]
}
```

### Controller Code

```dart
class MyOcrController extends GetxController {
  final dynamicFieldService = DynamicFieldService();
  final Rx<DynamicExtractedData> extractedData = 
      Rx<DynamicExtractedData>(DynamicExtractedData());

  @override
  void onInit() async {
    super.onInit();
    await dynamicFieldService.initialize();
  }

  Future<void> extractFromImage(XFile imageFile) async {
    // Get OCR text
    final rawText = await ocrService.recognizeText(imageFile);
    
    // Extract using dynamic config
    final fields = dynamicFieldService.extractAllFields(rawText);
    
    // Store in dynamic model
    extractedData.value = DynamicExtractedData.fromExtractedFields(fields);
    
    // User now has: name, email, phone (based on config)
  }
}
```

### UI Code (Static)

```dart
class MyFormScreen extends StatefulWidget {
  @override
  State<MyFormScreen> createState() => _MyFormScreenState();
}

class _MyFormScreenState extends State<MyFormScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        TextField(
          controller: nameController,
          decoration: InputDecoration(labelText: 'Name'),
        ),
        TextField(
          controller: emailController,
          decoration: InputDecoration(labelText: 'Email'),
        ),
        TextField(
          controller: phoneController,
          decoration: InputDecoration(labelText: 'Phone'),
        ),
        ElevatedButton(
          onPressed: () {
            // Extract data
            final data = controller.getExtractedDataMap();
            
            // Populate your form
            nameController.text = data['name']?.toString() ?? '';
            emailController.text = data['email']?.toString() ?? '';
            phoneController.text = data['phone']?.toString() ?? '';
          },
          child: Text('Extract Data'),
        ),
      ],
    );
  }
}
```

---

## 🔍 Data Types Support

| Type | Example | Parsing |
|------|---------|---------|
| **String** | "John Doe" | No conversion |
| **int** | 28 | `int.parse()` |
| **double** | 3.14 | `double.parse()` |
| **bool** | true | "true" or "1" → true |
| **DateTime** | 2026-07-29 | `DateTime.parse()` |

---

## 📊 JSON Output Example

### Input (Raw OCR Text)
```
Name: John Doe
Email: john@example.com
Phone: MM19779347
```

### field_config.json
```json
{
  "fields": [
    {"id": "name", "content_name": "name||Name", "type": "String", ...},
    {"id": "email", "content_name": "email||Email", "type": "String", ...},
    {"id": "phone", "content_name": "phone||Phone||Number", "type": "String", ...}
  ]
}
```

### Extracted JSON
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "MM19779347",
  "extractedAt": "2026-07-29T12:08:24.075+05:30"
}
```

---

## 🎯 Key Benefits

✅ **Flexible**: Add/remove fields just by editing JSON  
✅ **Dynamic**: No recompilation needed for field changes  
✅ **Simple Config**: Only 2 main properties (content_name + type)  
✅ **Manual UI**: You control exactly what fields appear  
✅ **Type-Safe**: Automatic type conversion based on config  
✅ **Extensible**: Easy to add new field types or patterns  
✅ **Backward Compatible**: Regex and patterns still work  

---

## ⚙️ API Reference

### DynamicFieldService

```dart
// Initialize
await dynamicFieldService.initialize();

// Extract all fields
Map<String, dynamic> fields = dynamicFieldService.extractAllFields(text);

// Get all field configs
List<DynamicFieldConfig> configs = dynamicFieldService.getAllFields();

// Get specific field config
DynamicFieldConfig? config = dynamicFieldService.getFieldById('name');

// Add field
dynamicFieldService.addField(newFieldConfig);

// Update field
dynamicFieldService.updateField('name', updatedConfig);

// Remove field
dynamicFieldService.removeField('name');

// Get debug info
print(dynamicFieldService.getDebugInfo());
```

### DynamicExtractedData

```dart
// Create from extracted fields
var data = DynamicExtractedData.fromExtractedFields(
  {'name': 'John', 'age': 28},
  rawText: 'raw ocr text',
);

// Get field value
var name = data.getField('name');

// Set field value
data.setField('name', 'Jane');

// Check if field exists
if (data.hasField('phone')) { ... }

// Check if any data exists
if (data.hasData()) { ... }

// Get field count
int count = data.getFieldCount();

// Get all fields
Map<String, dynamic> all = data.getAllFields();

// Convert to JSON
String json = data.toJsonString();
Map<String, dynamic> jsonMap = data.toJson();

// Create from JSON
var data = DynamicExtractedData.fromJsonString(jsonString);

// Clear all
data.clear();
```

---

## 🚀 Migration from Static System

If you were using the old static ExtractedData:

### Old (Static)
```dart
final data = TextExtractionService().extractFromText(text);
print(data.name);
print(data.age);
```

### New (Dynamic)
```dart
final fields = dynamicFieldService.extractAllFields(text);
final data = DynamicExtractedData.fromExtractedFields(fields);
print(data.getField('name'));
print(data.getField('age'));
```

---

## 📝 Summary

The new **dynamic field system** allows you to:

1. **Configure fields** in simple JSON (just content_name + type)
2. **Extraction automatically adapts** to your configuration
3. **Build UI statically** with exactly the fields you need
4. **Add/modify fields** without code changes
5. **Type-safe data handling** with automatic conversion
6. **Keep regex patterns** for powerful extraction

This gives you maximum flexibility while keeping the configuration simple! 🎉

---

**Version**: 2.0 (Dynamic Edition)  
**Status**: ✅ Production Ready  
**Date**: 2026-07-29
