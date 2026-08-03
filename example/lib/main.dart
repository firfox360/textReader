import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:textreder_example/views/views/ocr_view.dart';

import 'bindings/bindings/ocr_binding.dart';
import 'config/config/app_config.dart';
import 'config/config/app_theme.dart';

void main() {
  runApp(const TextrederExampleApp());
}

class TextrederExampleApp extends StatelessWidget {
  const TextrederExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConfig.appName,
      theme: AppTheme.lightTheme(),
      // darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system,
      home: const OcrView(),
      initialBinding: OcrBinding(),
      debugShowCheckedModeBanner: false,
    );
  }
}
