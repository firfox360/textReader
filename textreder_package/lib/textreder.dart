/// Textreder - Extract structured data from document images
/// 
/// ## Usage
/// 
/// ```dart
/// final service = TextrederService(
///   configPath: 'assets/field_config.json',
/// );
/// 
/// await service.initialize();
/// 
/// final result = await service.processImage(imageFile);
/// 
/// if (result.success) {
///   print(result.data); // Map<String, dynamic> with field IDs as keys
///   // Output: {'name': 'John Doe', 'phone': 'MM19779347', ...}
/// }
/// ```
/// 
/// ## Key Classes
/// 
/// - [TextrederService] - Main public API
/// - [ExtractionResult] - Result model containing extracted data
/// - [FieldConfig] - Field configuration model
/// - [ImageProcessor] - Handles image to text conversion
/// - [TextExtractor] - Handles text to structured data extraction

// ignore_for_file: unnecessary_library_name
library textreder;

export 'src/services/textreder_service.dart';
export 'src/models/extraction_result.dart';
export 'src/models/field_config.dart';
export 'src/processors/image_processor.dart';
export 'src/processors/text_extractor.dart';
export 'src/exceptions/textreder_exceptions.dart';
