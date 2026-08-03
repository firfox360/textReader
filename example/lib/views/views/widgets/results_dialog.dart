import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';

import '../../../config/config/app_config.dart';
import '../../../config/config/app_theme.dart';
import '../../../controllers/controllers/ocr_controller.dart';

/// Results dialog for displaying captured and processed data
class ResultsDialog extends StatelessWidget {
  final OcrController controller;

  const ResultsDialog({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(AppConfig.defaultBorderRadius),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppConfig.defaultBorderRadius),
                    topRight: Radius.circular(AppConfig.defaultBorderRadius),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Capture & Process Results',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Section
                    _buildSummarySection(),
                    const SizedBox(height: 16),

                    // Extracted Fields Section
                    _buildExtractedFieldsSection(),
                    const SizedBox(height: 16),

                    // JSON Section
                    _buildJsonSection(),
                    const SizedBox(height: 16),

                    // Raw Text Section
                    _buildRawTextSection(),
                  ],
                ),
              ),

              // Action buttons
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 16,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.check),
                        label: const Text('Accept'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          controller.copyJsonToClipboard();
                        },
                        icon: const Icon(Icons.copy),
                        label: const Text('Copy JSON'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    final result = controller.extractionResult.value;
    return _buildSection(
      'Summary',
      Colors.blue[50]!,
      Colors.blue[700]!,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Fields Found:', result.data.length.toString()),
          _buildInfoRow('Extraction Success:', result.success ? '✓ Yes' : '✗ No'),
          _buildInfoRow('Extracted At:', result.extractedAt.toString()),
        ],
      ),
    );
  }

  Widget _buildExtractedFieldsSection() {
    final result = controller.extractionResult.value;
    final data = result.data;
    
    return _buildSection(
      'Extracted Fields',
      Colors.green[50]!,
      Colors.green[700]!,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data.isEmpty)
            const Text(
              'No fields extracted',
              style: TextStyle(color: Colors.grey),
            )
          else
            ...data.entries.map((entry) => 
              _buildFieldRow('${entry.key}:', entry.value?.toString() ?? 'N/A')
            ),
        ],
      ),
    );
  }

  Widget _buildJsonSection() {
    final result = controller.extractionResult.value;
    final jsonString = jsonEncode(result.data);
    return _buildSection(
      'JSON Output',
      Colors.purple[50]!,
      Colors.purple[700]!,
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: SelectableText(
          jsonString,
          style: const TextStyle(
            fontSize: 11,
            fontFamily: 'Courier',
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildRawTextSection() {
    final rawText = controller.appState.rawText.value;
    return _buildSection(
      'Raw OCR Text',
      Colors.grey[100]!,
      Colors.grey[700]!,
      Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxHeight: 150),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[400]!),
        ),
        child: SingleChildScrollView(
          child: SelectableText(
            rawText.isEmpty ? 'No text detected' : rawText,
            style: TextStyle(
              fontSize: 11,
              fontFamily: 'Courier',
              color: rawText.isEmpty ? Colors.grey[600] : Colors.black87,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    Color backgroundColor,
    Color borderColor,
    Widget child,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: borderColor,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildFieldRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
