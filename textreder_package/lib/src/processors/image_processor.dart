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
