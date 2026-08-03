import 'package:get/get.dart';

import '../../controllers/controllers/ocr_controller.dart';

/// Binding for OcrController - dependency injection
class OcrBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OcrController>(() => OcrController());
  }
}
