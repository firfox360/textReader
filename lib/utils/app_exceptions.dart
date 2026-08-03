/// Custom exceptions for the application
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'AppException: $message${code != null ? ' ($code)' : ''}';
}

class CameraException extends AppException {
  CameraException(String message, {dynamic originalError})
      : super(
          message: message,
          code: 'CAMERA_ERROR',
          originalError: originalError,
        );
}

class ImageProcessingException extends AppException {
  ImageProcessingException(String message, {dynamic originalError})
      : super(
          message: message,
          code: 'IMAGE_PROCESSING_ERROR',
          originalError: originalError,
        );
}

class TextRecognitionException extends AppException {
  TextRecognitionException(String message, {super.originalError})
      : super(
          message: message,
          code: 'TEXT_RECOGNITION_ERROR',
        );
}

class DataExtractionException extends AppException {
  DataExtractionException(String message, {super.originalError})
      : super(
          message: message,
          code: 'DATA_EXTRACTION_ERROR',
        );
}
