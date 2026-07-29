# Textreder - OCR Text Extraction Application

A professional Flutter application that uses OCR (Optical Character Recognition) to extract text from images and automatically converts it into structured, clean JSON data.

## 🎯 Purpose

Extract structured information from documents (photos, ID cards, forms, etc.) and automatically populate form fields with accurate data using intelligent pattern matching.

## 🏗️ Architecture

This project follows the **MVC (Model-View-Controller) pattern** with **GetX state management**.

```
lib/
├── main.dart                          # App entry point
├── config/
│   ├── app_config.dart               # App constants
│   └── app_theme.dart                # Theme & styling
├── models/
│   ├── extracted_data.dart           # OCR result model
│   ├── app_state.dart                # Global app state
│   └── field_config.dart             # Field configuration
├── controllers/
│   └── ocr_controller.dart           # Business logic
├── views/
│   ├── ocr_view.dart                 # Main screen
│   └── widgets/results_dialog.dart   # Result dialog
├── services/
│   ├── camera_service.dart           # Camera & OCR
│   └── text_extraction_service.dart  # Smart extraction
├── widgets/
│   └── custom_widgets.dart           # Reusable UI components
├── utils/
│   ├── app_logger.dart               # Logging
│   ├── app_exceptions.dart           # Custom exceptions
│   └── app_utils.dart                # Helper utilities
├── bindings/
│   └── ocr_binding.dart              # Dependency injection
└── routes/
    └── app_routes.dart               # Navigation
```

## 📊 Data Flow

```
Image Selection/Capture
    ↓
CameraService.recognizeText() [ML Kit OCR]
    ↓
Raw Text (String)
    ↓
TextExtractionService.extractFromText()
    ↓
Smart Regex Pattern Matching
    ↓
ExtractedData Model
    ↓
JSON Output + UI Display
```

## 🔍 Extracted Fields

| Field | Type | Example |
|-------|------|---------|
| **Name** | Text | John Doe |
| **Age** | Number | 28 |
| **Gender** | Choice | Male/Female/Other |
| **Address** | Text | 123 Main St, City |
| **Phone** | Alphanumeric | MM19779347, +1-555-0123 |
| **Email** | Email | john@example.com |
| **Date of Birth** | Date | 01/15/1996 |
| **Document ID** | Text | IL-DL-1234567 |

Plus unlimited **custom fields** support.

## 🚀 Key Features

✅ **Smart OCR** - Uses google_mlkit_text_recognition  
✅ **Flexible Extraction** - Handles multiple text formats  
✅ **Alphanumeric Support** - Extracts phone numbers like MM19779347  
✅ **Clean JSON Output** - Only populated fields included  
✅ **Reactive UI** - Real-time updates with GetX  
✅ **Professional Code** - MVC, clean architecture, no dead code  
✅ **Camera & Gallery** - Capture or select images  
✅ **Custom Fields** - Extend with additional fields  

## 📱 Technology Stack

- **Framework**: Flutter 3.7+
- **Language**: Dart
- **State Management**: GetX 4.6.5
- **OCR Engine**: google_mlkit_text_recognition 0.15.0
- **Camera**: camera 0.11.0+1
- **Image Picker**: image_picker 1.1.2
- **Permissions**: permission_handler 12.0.3

## 💻 Setup & Usage

### Requirements
- Flutter 3.7.0+
- Dart SDK
- Android SDK (for Android build)
- Xcode (for iOS build)

### Installation

```bash
# Clone repository
git clone <repo-url>
cd textreder

# Install dependencies
flutter pub get

# Run app
flutter run
```

### Build Release

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## 🔧 Usage Example

```dart
// 1. Capture or select image
final imageFile = await cameraService.pickFromCamera();

// 2. Recognize text
final rawText = await cameraService.recognizeText(imageFile);

// 3. Extract structured data
final extractedData = TextExtractionService().extractFromText(rawText);

// 4. Access extracted fields
print(extractedData.name);        // "John Doe"
print(extractedData.phone);       // "MM19779347"
print(extractedData.email);       // "john@example.com"

// 5. Convert to JSON
final json = extractedData.toJsonString();
```

## 📊 JSON Output Example

```json
{
  "name": "John Doe",
  "age": "28",
  "gender": "Male",
  "address": "123 Main Street, Springfield, IL 62701",
  "phone": "MM19779347",
  "email": "john.doe@example.com",
  "dateOfBirth": "01/15/1996",
  "documentId": "IL-DL-1234567",
  "extractedAt": "2026-07-29T11:49:03.988+05:30"
}
```

## 🧪 Testing

Test with various document formats:
- ✅ ID Cards
- ✅ Passports
- ✅ Driver's Licenses
- ✅ Business Cards
- ✅ Forms with text fields
- ✅ Screenshots with structured data

## 📖 Documentation

- **MVC_ARCHITECTURE.md** - Detailed architecture explanation
- **EXTRACTION_IMPROVEMENTS.md** - Recent enhancements

## ✨ Code Quality

- ✅ No dead code
- ✅ Clean imports
- ✅ Professional structure
- ✅ Well-documented
- ✅ Type-safe Dart
- ✅ Following Flutter best practices

## 🐛 Error Handling

The app handles:
- Missing permissions
- Camera unavailable
- No text detected
- Empty images
- Processing errors
- Type conversion issues

## 🎨 UI/UX Features

- Modern Material Design
- Responsive layout
- Loading indicators
- Error messages
- Success notifications
- Real-time form updates
- Accessible controls

## 🔐 Permissions

Requires:
- `CAMERA` - For image capture
- `READ_EXTERNAL_STORAGE` - For gallery access
- `WRITE_EXTERNAL_STORAGE` - For file operations (optional)

## 📝 License

[Add your license here]

## 👥 Contributing

[Add contribution guidelines here]

## 📞 Support

For issues or questions, please open a GitHub issue.

---

**Status**: ✅ Production Ready  
**Version**: 2.0  
**Last Updated**: 2026-07-29

