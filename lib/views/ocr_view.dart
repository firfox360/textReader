import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/ocr_controller.dart';
import '../config/app_config.dart';
import '../config/app_theme.dart';
import '../widgets/custom_widgets.dart';
import 'widgets/results_dialog.dart';

/// Main OCR Scanner View - Production level MVC
class OcrView extends GetView<OcrController> {
  const OcrView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Obx(
        () => Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(AppConfig.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Error message display
                  if (controller.appState.hasError.value)
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppConfig.defaultPadding,
                      ),
                      child: ErrorMessage(
                        message: controller.appState.errorMessage?.value ?? '',
                        onDismiss: () =>
                            controller.appState.clearError(),
                      ),
                    ),

                  // Success message display
                  if (controller.appState.isSuccess.value)
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppConfig.defaultPadding,
                      ),
                      child: SuccessMessage(
                        message:
                            'Successfully extracted ${controller.appState.extractedData.value.getFieldCount()} fields',
                      ),
                    ),

                  // Action buttons section
                  _buildActionButtonsSection(context),
                  const SizedBox(height: AppConfig.defaultPadding * 1.5),

                  // Extracted data form section
                  if (controller.appState.extractedData.value.hasData())
                    _buildFormSection(),
                  const SizedBox(height: AppConfig.defaultPadding),
                ],
              ),
            ),

            // Loading overlay
            LoadingOverlay(
              isLoading: controller.appState.isLoading.value ||
                  controller.appState.isProcessing.value,
              message: controller.appState.isLoading.value
                  ? 'Processing image...'
                  : 'Preparing camera...',
            ),
          ],
        ),
      ),
    );
  }

  /// Build app bar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(AppConfig.appName),
      elevation: 0,
      actions: [
        Obx(
          () => IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: controller.appState.extractedData.value.hasData()
                ? controller.clearAll
                : null,
            tooltip: 'Clear all data',
          ),
        ),
      ],
    );
  }

  /// Build action buttons section
  Widget _buildActionButtonsSection(BuildContext context) {
    return Column(
      children: [
        // Camera and Gallery buttons
        Row(
          children: [
            Expanded(
              child: CustomButton(
                label: 'Camera',
                leadingIcon: const Icon(Icons.camera_alt),
                isLoading: controller.appState.isProcessing.value,
                onPressed: controller.captureFromCamera,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                label: 'Gallery',
                leadingIcon: const Icon(Icons.image),
                isLoading: controller.appState.isProcessing.value,
                onPressed: controller.pickFromGallery,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
/*
        // Capture and Process button
        Obx(
          () => CustomButton(
            label: 'Capture & Process',
            leadingIcon: const Icon(Icons.camera_enhance),
            isLoading: controller.appState.isProcessing.value,
            onPressed: () => _showCaptureProcessDialog(context),
          ),
        ),*/
      ],
    );
  }

  /// Build form section with extracted data
  Widget _buildFormSection() {
    return InfoCard(
      title: 'Extracted Information',
      headerColor: AppTheme.primaryColor,
      child: Obx(
        () {
          final fields = controller.getAvailableFields();
          
          if (fields.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No fields configured in field_config.json',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final extractedData = controller.dynamicExtractedData.value;
          
          return Column(
            children: fields.map((field) {
              final value = extractedData.getField(field.id) ?? '';
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: CustomTextField(
                  label: field.id,
                  hintText: 'Enter ${field.id}',
                  controller: TextEditingController(text: value.toString()),
                  onChanged: (newValue) {
                    controller.updateFieldValue(field.id, newValue);
                  },
                  prefixIcon: const Icon(Icons.info),
                  readOnly: false,
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

