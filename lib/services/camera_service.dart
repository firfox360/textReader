import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

/// Service for camera and image recognition
class CameraService {
  static final CameraService _instance = CameraService._internal();

  factory CameraService() {
    return _instance;
  }

  CameraService._internal();

  final ImagePicker _imagePicker = ImagePicker();
  late TextRecognizer _textRecognizer;

  /// Initialize the text recognizer
  void initialize() {
    _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  }

  /// Pick image from camera
  Future<XFile?> pickFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
      );
      return image;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error picking from camera: $e');
      }
      return null;
    }
  }

  /// Pick image from gallery
  Future<XFile?> pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );
      return image;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error picking from gallery: $e');
      }
      return null;
    }
  }

  /// Recognize text from image file
  Future<String> recognizeText(XFile imageFile) async {
    try {
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final recognizedText = await _textRecognizer.processImage(inputImage);


      if (kDebugMode) {
        print("extracted text ------------------- : ${recognizedText.text}");
      }

      String extractedText = '';
      for (TextBlock textBlock in recognizedText.blocks) {
        extractedText += '${textBlock.text}\n';
      }

      return extractedText.trim();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error recognizing text: $e');
      }
      rethrow;
    }
  }

  /// Clean up resources
  Future<void> dispose() async {
    await _textRecognizer.close();
  }
}
