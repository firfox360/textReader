import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../models/app_state.dart';
import '../services/camera_service.dart';
import '../services/dynamic_field_service.dart';

/// Main OCR Scanner Controller - Dynamic field extraction
class OcrController extends GetxController {
  // Services
  final CameraService _cameraService = CameraService();
  final DynamicFieldService _dynamicFieldService = DynamicFieldService();

  // State
  late AppState appState;

  // Dynamic extracted data (flexible, changes based on field_config.json)
  final Rx<DynamicExtractedData> dynamicExtractedData = 
      Rx<DynamicExtractedData>(DynamicExtractedData());

  // Form controllers map - user creates these in their UI based on their needs
  final Map<String, TextEditingController> formControllers = {};

  @override
  void onInit() {
    super.onInit();
    appState = AppState();
    _cameraService.initialize();
    _initializeDynamicFields();
  }

  /// Initialize dynamic fields from config
  Future<void> _initializeDynamicFields() async {
    try {
      await _dynamicFieldService.initialize();
      
      if (kDebugMode) {
        print(_dynamicFieldService.getDebugInfo());
      }
    } catch (e) {
      appState.setError('Failed to load field configuration: $e');
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

  /// Process image with OCR and extract data dynamically
  Future<void> _processImage(XFile imageFile) async {
    try {
      appState.setLoading(true);

      // Recognize text from image
      final rawText = await _cameraService.recognizeText(imageFile);
      appState.setRawText(rawText);

      if (rawText.isEmpty) {
        appState.setError('No text detected in image');
        appState.setLoading(false);
        return;
      }

      // Extract data dynamically based on field_config.json
      final extractedFields = _dynamicFieldService.extractAllFields(rawText);
      
      // Create dynamic extracted data
      final extractedData = DynamicExtractedData.fromExtractedFields(
        extractedFields,
        rawText: rawText,
      );
      
      dynamicExtractedData.value = extractedData;
      appState.setSuccess(true);
      
      _printDebugInfo(rawText, extractedData);
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
        final value = dynamicExtractedData.value.getField(fieldId);
        if (value != null) {
          controller.text = value.toString();
        }
      }
    }
  }

  /// Get extracted value for a specific field
  dynamic getFieldValue(String fieldId) {
    return dynamicExtractedData.value.getField(fieldId);
  }

  /// Update a field value
  void updateFieldValue(String fieldId, dynamic value) {
    dynamicExtractedData.value.setField(fieldId, value);
    
    // Update form controller if it exists
    final controller = formControllers[fieldId];
    if (controller != null) {
      controller.text = value.toString();
    }
  }

  /// Get all extracted data as JSON
  String getExtractedJsonString() {
    return dynamicExtractedData.value.toJsonString();
  }

  /// Get all extracted data as Map
  Map<String, dynamic> getExtractedDataMap() {
    return dynamicExtractedData.value.getAllFields();
  }

  /// Clear all data
  void clearAll() {
    appState.reset();
    dynamicExtractedData.value.clear();
    for (final controller in formControllers.values) {
      controller.clear();
    }
  }

  /// Get field configuration (for UI building)
  List<DynamicFieldConfig> getAvailableFields() {
    return _dynamicFieldService.getAllFields();
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
  void _printDebugInfo(String rawText, DynamicExtractedData data) {
    if (kDebugMode) {
      debugPrint(
        '\n════════════════════════════════════════════════════════════════════════════\n'
        '📸 OCR PROCESSING COMPLETE (DYNAMIC EXTRACTION)\n'
        '════════════════════════════════════════════════════════════════════════════\n'
        'RAW TEXT:\n$rawText\n\n'
        'EXTRACTED DATA:\n'
        '${data.getAllFields().entries.map((e) => '  ${e.key}: ${e.value}').join('\n')}\n\n'
        'FIELD COUNT: ${data.getFieldCount()}\n\n'
        'JSON OUTPUT:\n${data.toJsonString()}\n'
        '════════════════════════════════════════════════════════════════════════════\n'
      );
    }
  }
}
