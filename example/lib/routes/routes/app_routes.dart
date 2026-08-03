import 'package:get/get.dart';
import '../../bindings/bindings/ocr_binding.dart';
import '../../config/config/app_config.dart';
import '../../views/views/ocr_view.dart';

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
