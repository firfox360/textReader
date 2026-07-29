import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../models/app_state.dart';
import '../services/camera_service.dart';
import '../textreder.dart';

/// Main OCR Scanner Controller - Uses Textreder Package
class OcrController extends GetxController {
  // Services
  final CameraService _cameraService = CameraService();
  final TextrederService _textrederService = TextrederService(
    configPath: 'assets/field_config.json',
  );

  // State
  late AppState appState;

  // Extracted data result from Textreder package
  final Rx<ExtractionResult> extractionResult = Rx<ExtractionResult>(
    ExtractionResult(
      data: {},
      rawText: '',
      extractedAt: DateTime.now(),
      success: false,
    ),
  );

  // Form controllers map - user creates these in their UI based on their needs
  final Map<String, TextEditingController> formControllers = {};

  @override
  void onInit() {
    super.onInit();
    appState = AppState();
    _cameraService.initialize();
    _initializeTextreder();
  }

  /// Initialize Textreder service
  Future<void> _initializeTextreder() async {
    try {
      await _textrederService.initialize();
      
      if (kDebugMode) {
        debugPrint(_textrederService.getDebugInfo());
      }
    } catch (e) {
      appState.setError('Failed to initialize Textreder: $e');
    }
  }

  @override
  void onClose() {
    // Dispose all form controllers
    for (final controller in formControllers.values) {
      controller.dispose();
    }
    _cameraService.dispose();
    super.onClose();
  }

  /// Capture and process image from camera
  Future<void> captureFromCamera() async {
    try {
      appState.setProcessing(true);
      appState.clearError();

      final imageFile = await _cameraService.pickFromCamera();
      if (imageFile == null) {
        appState.setError('No image selected from camera');
        appState.setProcessing(false);
        return;
      }

      await _processImage(imageFile);
    } catch (e) {
      appState.setError('Error capturing from camera: $e');
    } finally {
      appState.setProcessing(false);
    }
  }

  /// Pick and process image from gallery
  Future<void> pickFromGallery() async {
    try {
      appState.setProcessing(true);
      appState.clearError();

      final imageFile = await _cameraService.pickFromGallery();
      if (imageFile == null) {
        appState.setError('No image selected from gallery');
        appState.setProcessing(false);
        return;
      }

      await _processImage(imageFile);
    } catch (e) {
      appState.setError('Error picking from gallery: $e');
    } finally {
      appState.setProcessing(false);
    }
  }

  /// Process image with OCR and extract data using Textreder
  Future<void> _processImage(XFile imageFile) async {
    try {
      appState.setLoading(true);

      // Use Textreder package to process image and extract data
      // Returns ExtractionResult with Map<String, dynamic> containing field IDs as keys
      final result = await _textrederService.processImage(imageFile);
      
      extractionResult.value = result;
      appState.setRawText(result.rawText);

      if (result.success) {
        if (result.data.isEmpty) {
          appState.setError('No data extracted from image');
        } else {
          appState.setSuccess(true);
          _printDebugInfo(result);
        }
      } else {
        appState.setError('Extraction failed: ${result.errors.join(', ')}');
      }
    } catch (e) {
      appState.setError('Error processing image: $e');
    } finally {
      appState.setLoading(false);
    }
  }

  /// Populate form fields from extracted data
  /// User calls this method with the field IDs they want to populate
  void populateFormFields(List<String> fieldIds) {
    for (final fieldId in fieldIds) {
      final controller = formControllers[fieldId];
      if (controller != null) {
        final value = extractionResult.value.data[fieldId];
        if (value != null) {
          controller.text = value.toString();
        }
      }
    }
  }

  /// Get extracted value for a specific field
  dynamic getFieldValue(String fieldId) {
    return extractionResult.value.data[fieldId];
  }

  /// Update a field value
  void updateFieldValue(String fieldId, dynamic value) {
    extractionResult.value.data[fieldId] = value;
    
    // Update form controller if it exists
    final controller = formControllers[fieldId];
    if (controller != null) {
      controller.text = value.toString();
    }
  }

  /// Get all extracted data as JSON
  String getExtractedJsonString() {
    return jsonEncode(extractionResult.value.data);
  }

  /// Get all extracted data as Map
  Map<String, dynamic> getExtractedDataMap() {
    return extractionResult.value.data;
  }

  /// Clear all data
  void clearAll() {
    appState.reset();
    extractionResult.value = ExtractionResult(
      data: {},
      rawText: '',
      extractedAt: DateTime.now(),
      success: false,
    );
    for (final controller in formControllers.values) {
      controller.clear();
    }
  }

  /// Get field configuration (for UI building)
  List<FieldConfig> getAvailableFields() {
    return _textrederService.getFieldConfigs();
  }

  /// Copy extracted JSON to clipboard
  Future<void> copyJsonToClipboard() async {
    try {
      final json = getExtractedJsonString();
      await Clipboard.setData(ClipboardData(text: json));
      Get.snackbar(
        'Success',
        'JSON copied to clipboard',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to copy JSON: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Private helper for debug logging
  void _printDebugInfo(ExtractionResult result) {
    if (kDebugMode) {
      debugPrint(result.prettyPrint());
    }
  }
}
