import 'package:get/get.dart';
import '../bindings/ocr_binding.dart';
import '../views/ocr_view.dart';
import '../config/app_config.dart';

/// Application routes
class AppRoutes {
  static final routes = [
    GetPage(
      name: AppConfig.routeHome,
      page: () => const OcrView(),
      binding: OcrBinding(),
      transition: Transition.fadeIn,
    ),
  ];
}
