# TextReder Example App

This is a complete example application demonstrating how to use the [TextReder](https://pub.dev/packages/textreder) package for OCR document extraction.

## Features Demonstrated

- ✅ Image capture from camera and gallery
- ✅ OCR text extraction using ML Kit
- ✅ Structured data extraction with regex
- ✅ Dynamic field configuration
- ✅ Type conversion and validation
- ✅ Beautiful UI with Material Design

## Getting Started

### Prerequisites

- Flutter SDK >= 3.0.0
- Dart >= 3.0.0

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/textreder.git
cd textreder/example
```

2. Get dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                  # Entry point
├── config/
│   ├── app_config.dart        # App constants
│   └── app_theme.dart         # Theme configuration
├── controllers/
│   └── ocr_controller.dart    # OCR logic using TextReder
├── views/
│   ├── ocr_view.dart          # Main screen
│   └── widgets/
│       └── results_dialog.dart # Results display
├── models/
│   ├── app_state.dart         # App state management
│   └── extracted_data.dart    # Legacy data model
├── services/
│   ├── camera_service.dart    # Camera & image handling
│   └── text_extraction_service.dart  # Legacy extraction
├── widgets/
│   └── custom_widgets.dart    # Reusable widgets
├── utils/
│   ├── app_utils.dart         # Utility functions
│   ├── app_logger.dart        # Logging
│   └── app_exceptions.dart    # Exception handling
└── bindings/
    └── ocr_binding.dart       # GetX bindings
```

## Configuration

### field_config.json

The app uses `assets/field_config.json` to configure extraction fields. Example:

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

## How It Works

1. **User Action**: User captures/selects an image
2. **OCR Processing**: Image is processed using Google ML Kit
3. **Field Extraction**: Raw text is matched against configured regex patterns
4. **Type Conversion**: Extracted values are converted to configured types
5. **Display Results**: Extracted data is displayed to user as `Map<String, dynamic>`

## Using TextReder Package

### Initialize

```dart
final service = TextrederService(
  configPath: 'assets/field_config.json',
);
await service.initialize();
```

### Process Image

```dart
final result = await service.processImage(imageFile);

if (result.success) {
  print(result.data);  // Map<String, dynamic>
}
```

### Access Data

```dart
final name = result.data['name'];    // Using field ID from config
final phone = result.data['phone'];
final age = result.data['age'];      // Auto-converted to int
```

## UI Components

### Main Screen (OcrView)
- Camera capture button
- Gallery selection button
- Extracted data display
- Form for manual editing

### Results Dialog
- Summary of extraction
- Extracted fields display
- Raw OCR text view
- Copy JSON button

## Error Handling

The app handles various error scenarios:
- Image processing failures
- Invalid configurations
- Extraction errors
- Permission issues

## Customization

### Change Field Configuration

Edit `assets/field_config.json` to add/remove/modify fields. The app will automatically adjust.

### Modify UI

All UI components are in `lib/views/` and `lib/widgets/`. Customize as needed.

### Adjust Regex Patterns

Update regex patterns in `field_config.json` for better accuracy.

## Dependencies

- **get**: State management and routing
- **image_picker**: Camera and gallery access
- **textreder**: OCR and data extraction

## Permissions

### Android
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

### iOS
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to scan documents</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to select images</string>
```

## Troubleshooting

### App crashes on startup
- Ensure `assets/field_config.json` exists
- Verify JSON syntax is correct
- Check pubspec.yaml assets section

### No text extracted
- Check regex patterns in field_config.json
- Verify image quality is sufficient
- Test with clear document images

### Permission denied errors
- Grant camera/storage permissions
- Check Android/iOS permission configurations
- Restart the app after granting permissions

## Testing

The example includes test cases in the `test/` directory:

```bash
flutter test
```

## Resources

- [TextReder Package](https://pub.dev/packages/textreder)
- [Flutter Documentation](https://flutter.dev/docs)
- [Google ML Kit](https://developers.google.com/ml-kit)
- [Regular Expressions](https://regex101.com/)

## Contributing

Found a bug or have a feature request? Please open an issue on GitHub.

## License

This example app is licensed under the MIT License - see [LICENSE](../LICENSE) file for details.

## Support

For questions or issues with the example app:
1. Check the [TextReder documentation](../textreder_package/README.md)
2. Search [GitHub issues](https://github.com/yourusername/textreder/issues)
3. Open a new issue with detailed information

## Next Steps

Try extending this example by:
- Adding more field types
- Implementing batch processing
- Adding data validation
- Creating custom regex patterns
- Building a database to store results

Happy coding! 🎉
