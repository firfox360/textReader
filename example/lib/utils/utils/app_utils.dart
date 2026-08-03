import 'package:image_picker/image_picker.dart';

/// Helper utilities for image and file operations
class ImageUtils {
  /// Validate image file extension
  static bool isValidImageFile(String filePath) {
    final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    return validExtensions.any((ext) => filePath.toLowerCase().endsWith(ext));
  }

  /// Get file size in MB
  static Future<double> getFileSizeInMB(String filePath) async {
    try {
      final file = XFile(filePath);
      final bytes = await file.readAsBytes();
      return bytes.length / (1024 * 1024);
    } catch (e) {
      return 0;
    }
  }
}

/// Helper utilities for string and text operations
class StringUtils {
  /// Check if string is numeric
  static bool isNumeric(String text) {
    return double.tryParse(text) != null;
  }

  /// Remove extra whitespace
  static String removeExtraWhitespace(String text) {
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Truncate text with ellipsis
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  /// Validate phone number format
  static bool isValidPhone(String phone) {
    return RegExp(r'^[+]?[\d\s\-()]{7,}$').hasMatch(phone);
  }
}
