import 'package:flutter/foundation.dart';

/// Application logger for debugging and production monitoring
class AppLogger {
  static const String _prefix = '🔹';

  static void debug(String message, {dynamic error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      debugPrint('$_prefix [DEBUG] $message');
      if (error != null) {
        debugPrint('Error: $error');
        if (stackTrace != null) {
          debugPrint('StackTrace: $stackTrace');
        }
      }
    }
  }

  static void info(String message) {
    if (kDebugMode) {
      debugPrint('$_prefix [INFO] $message');
    }
  }

  static void warning(String message) {
    if (kDebugMode) {
      debugPrint('⚠️  [WARNING] $message');
    }
  }

  static void error(String message, {dynamic error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      debugPrint('❌ [ERROR] $message');
      if (error != null) {
        debugPrint('Error: $error');
        if (stackTrace != null) {
          debugPrint('StackTrace: $stackTrace');
        }
      }
    }
  }

  static void success(String message) {
    if (kDebugMode) {
      debugPrint('✅ [SUCCESS] $message');
    }
  }
}
