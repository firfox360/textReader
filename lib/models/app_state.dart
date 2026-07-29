import 'package:get/get.dart';
import 'extracted_data.dart';

/// Application state model
class AppState {
  // Loading states
  RxBool isLoading = false.obs;
  RxBool isProcessing = false.obs;

  // Error states
  RxString? errorMessage = null;
  RxBool hasError = false.obs;

  // Data states
  RxString rawText = ''.obs;
  Rx<ExtractedData> extractedData = ExtractedData().obs;

  // UI states
  RxBool showRawText = false.obs;
  RxBool isSuccess = false.obs;

  void setLoading(bool value) {
    isLoading.value = value;
  }

  void setProcessing(bool value) {
    isProcessing.value = value;
  }

  void setError(String? message) {
    errorMessage?.value = message ?? '';
    hasError.value = message != null && message.isNotEmpty;
  }

  void clearError() {
    errorMessage?.value = '';
    hasError.value = false;
  }

  void setRawText(String text) {
    rawText.value = text;
  }

  void setExtractedData(ExtractedData data) {
    extractedData.value = data;
  }

  void setSuccess(bool value) {
    isSuccess.value = value;
  }

  void reset() {
    isLoading.value = false;
    isProcessing.value = false;
    hasError.value = false;
    errorMessage?.value = '';
    rawText.value = '';
    extractedData.value = ExtractedData();
    showRawText.value = false;
    isSuccess.value = false;
  }
}
