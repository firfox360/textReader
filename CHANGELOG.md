# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-08-03

### Added

#### Core API
- **TextrederService** - Main public API for OCR and structured data extraction
- **ExtractionResult** - Clean return model with success status and extracted data
- **FieldConfig** - Configuration model for field definitions and patterns
- **ImageProcessor** - Google ML Kit integration for image-to-text conversion
- **TextExtractor** - Intelligent regex-based text-to-data extraction

#### Features
- 📸 **Image Processing** - Supports camera capture and gallery selection via image_picker
- 🎯 **Smart Text Extraction** - Regex pattern matching for multiple field types
- 🔄 **Automatic Type Conversion** - String, int, double, bool, and DateTime conversions
- 📊 **JSON Configuration** - Field definitions via field_config.json
- ⚙️ **Flexible Field Management** - Add, update, and remove fields dynamically
- 🧠 **ML Kit OCR** - Google ML Kit Text Recognition (v0.15.0+)
- 📱 **Camera Support** - Real-time text capture and processing
- 🎨 **GetX Integration** - Reactive state management with controllers and bindings
- 🔐 **Permission Handling** - Automatic camera and storage permission requests

#### Services
- **CameraService** - Capture images and recognize text from camera/gallery
- **TextExtractionService** - Extract structured data using regex patterns
- **DynamicFieldService** - Manage field configurations at runtime

#### Models
- **ExtractedData** - Type-safe model for extracted field data
- **AppState** - Global application state management
- **FieldConfig** - Field type definitions with patterns and validators

#### Utilities
- **AppLogger** - Debug logging functionality
- **AppExceptions** - Custom exception hierarchy for error handling
- **AppUtils** - Helper utilities for common operations

#### Architecture
- **MVC Pattern** - Clean separation of models, views, and controllers
- **GetX State Management** - Reactive programming with GetX controllers
- **Dependency Injection** - Bindings for automatic service initialization
- **Navigation Routes** - Centralized route management with GetX

#### Documentation
- Comprehensive README with architecture overview
- API documentation for all public classes
- Usage examples for common scenarios
- Field configuration format specification
- Code examples showing text extraction flow

#### Testing
- Unit tests for text extraction logic
- Widget tests for UI components
- Example app demonstrating usage

### Supported Field Types
- **Text** - String values
- **Number** - Integer and decimal numbers
- **Email** - Email addresses with validation
- **Phone** - Phone numbers (alphanumeric support)
- **Date** - Date values with format detection
- **Choice** - Predefined options (Male/Female/Other)
- **Custom** - User-defined patterns and types

### Key Dependencies
- `flutter: ^3.0.0`
- `google_mlkit_text_recognition: ^0.15.0`
- `image_picker: ^1.1.2`
- `camera: ^0.11.0+1`
- `permission_handler: ^12.0.3`
- `get: ^4.6.5`

### Platform Support
- ✅ Android (API 21+)
- ✅ iOS (11.0+)

### Example Usage

```dart
// Initialize service
final service = TextrederService(
  configPath: 'assets/field_config.json',
);
await service.initialize();

// Process image
final result = await service.processImage(imageFile);

// Access extracted data
if (result.success) {
  print(result.data);
  // Output: {'name': 'John Doe', 'phone': 'MM19779347', 'email': 'john@example.com'}
}
```

### Configuration Example

```json
{
  "fields": [
    {
      "id": "name",
      "type": "text",
      "pattern": "^[A-Za-z\\s]+$",
      "label": "Full Name"
    },
    {
      "id": "phone",
      "type": "phone",
      "pattern": "[A-Z0-9]{2}\\d{8}",
      "label": "Phone Number"
    },
    {
      "id": "email",
      "type": "email",
      "pattern": "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}",
      "label": "Email Address"
    }
  ]
}
```

### Error Handling
- Custom exception types for different error scenarios
- Try-catch support with meaningful error messages
- Graceful degradation when fields cannot be extracted
- Detailed logging for debugging

### Quality Assurance
- ✅ No dead code
- ✅ Clean imports and architecture
- ✅ Professional code structure
- ✅ Type-safe Dart implementation
- ✅ Following Flutter best practices
- ✅ Comprehensive documentation
- ✅ Pub.dev package standards compliance

---

## [Unreleased]

### Planned Features
- [ ] Support for multiple OCR backends (Firebase ML Kit, Tesseract)
- [ ] Batch image processing
- [ ] Custom validation functions
- [ ] Field grouping and dependencies
- [ ] Performance optimizations for large documents
- [ ] Web platform support
- [ ] Internationalization (i18n)
- [ ] Advanced pattern matching with capture groups
- [ ] Caching for extracted data
- [ ] Integration with cloud services

### Under Investigation
- Improved accuracy for handwritten text
- Real-time OCR preview
- Document segmentation
- Multi-language support

---

## Previous Versions

### Version History Format
Each version number indicates:
- **MAJOR** (1.0.0) - Breaking changes
- **MINOR** (1.1.0) - New features, backward compatible
- **PATCH** (1.0.1) - Bug fixes, backward compatible

### Deprecation Policy
- Features marked for deprecation will be supported for at least 2 minor releases
- Users will be notified via documentation and code warnings
- Migration guides provided for breaking changes
