import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/config/app_config.dart';
import '../../config/config/app_theme.dart';
import '../../controllers/controllers/ocr_controller.dart';
import '../../widgets/widgets/custom_widgets.dart';

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
                            'Successfully extracted ${controller.extractionResult.value.data.length} fields',
                      ),
                    ),

                  // Action buttons section
                  _buildActionButtonsSection(context),
                  const SizedBox(height: AppConfig.defaultPadding * 1.5),

                  // Extracted data form section
                  if (controller.extractionResult.value.data.isNotEmpty)
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
            onPressed: controller.extractionResult.value.data.isNotEmpty
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

          final extractedData = controller.extractionResult.value.data;
          
          return Column(
            children: fields.map((field) {
              // Field ID is guaranteed to be non-null by FieldConfig definition
              final fieldId = field.id;
              if (fieldId.isEmpty) {
                return const SizedBox.shrink();
              }
              
              // Get value from extracted data, default to empty string if not found
              final value = extractedData[fieldId] ?? '';
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: CustomTextField(
                  label: fieldId,
                  hintText: 'Enter $fieldId',
                  controller: controller.formControllers.putIfAbsent(
                    fieldId,
                    () => TextEditingController(text: value.toString()),
                  ),
                  onChanged: (newValue) {
                    controller.updateFieldValue(fieldId, newValue);
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

