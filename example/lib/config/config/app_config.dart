/// Application configuration and constants
class AppConfig {
  // App Info
  static const String appName = 'TextReader - OCR Scanner';
  static const String appVersion = '1.0.0';

  // Routes
  static const String routeHome = '/';
  static const String routeScanner = '/scanner';
  static const String routeSplash = '/splash';

  // Timeouts
  static const Duration ocrTimeout = Duration(seconds: 30);
  static const Duration imagePickTimeout = Duration(seconds: 15);

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double defaultElevation = 4.0;
}
