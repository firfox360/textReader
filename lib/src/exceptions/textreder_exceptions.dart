/// Base exception for Textreder package
class TextrederException implements Exception {
  final String message;
  final dynamic originalError;

  TextrederException(
    this.message, {
    this.originalError,
  });

  @override
  String toString() => 'TextrederException: $message';
}

/// Exception for image processing errors
class ImageProcessingException extends TextrederException {
  ImageProcessingException(
    super.message, {
    super.originalError,
  });

  @override
  String toString() => 'ImageProcessingException: $message';
}

/// Exception for text extraction errors
class ExtractionException extends TextrederException {
  ExtractionException(
    super.message, {
    super.originalError,
  });

  @override
  String toString() => 'ExtractionException: $message';
}

/// Exception for configuration errors
class ConfigurationException extends TextrederException {
  ConfigurationException(
    super.message, {
    super.originalError,
  });

  @override
  String toString() => 'ConfigurationException: $message';
}
