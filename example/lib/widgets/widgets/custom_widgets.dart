import 'package:flutter/material.dart';

import '../../config/config/app_config.dart';
import '../../config/config/app_theme.dart';


/// Custom text field widget for form inputs
class CustomTextField extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final TextInputType keyboardType;
  final int maxLines;
  final bool readOnly;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const CustomTextField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.readOnly = false,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: keyboardType,
          maxLines: maxLines,
          readOnly: readOnly,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: readOnly ? Colors.grey[100] : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppConfig.defaultBorderRadius,
              ),
              borderSide: const BorderSide(
                color: Color(0xFFE0E0E0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppConfig.defaultBorderRadius,
              ),
              borderSide: const BorderSide(
                color: Color(0xFFE0E0E0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppConfig.defaultBorderRadius,
              ),
              borderSide: const BorderSide(
                color: AppTheme.primaryColor,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom button widget
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Widget? leadingIcon;
  final double width;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.leadingIcon,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: isOutlined
          ? OutlinedButton.icon(
              onPressed: isLoading ? null : onPressed,
              icon: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : (leadingIcon ?? const SizedBox()),
              label: Text(label),
            )
          : ElevatedButton.icon(
              onPressed: isLoading ? null : onPressed,
              icon: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : (leadingIcon ?? const SizedBox()),
              label: Text(label),
            ),
    );
  }
}

/// Loading overlay widget
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return const SizedBox();

    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.primaryColor,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error message widget
class ErrorMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;

  const ErrorMessage({
    super.key,
    required this.message,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withValues(alpha: 0.1),
        border: Border.all(color: AppTheme.errorColor),
        borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppTheme.errorColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppTheme.errorColor,
                fontSize: 14,
              ),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: onDismiss,
              color: AppTheme.errorColor,
            ),
        ],
      ),
    );
  }
}

/// Success message widget
class SuccessMessage extends StatelessWidget {
  final String message;

  const SuccessMessage({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withValues(alpha: 0.1),
        border: Border.all(color: AppTheme.successColor),
        borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: AppTheme.successColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppTheme.successColor,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card with gradient header
class InfoCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Color? headerColor;

  const InfoCard({
    super.key,
    required this.title,
    required this.child,
    this.headerColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppConfig.defaultElevation.toDouble(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppConfig.defaultPadding,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: headerColor ?? AppTheme.primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppConfig.defaultBorderRadius),
                topRight: Radius.circular(AppConfig.defaultBorderRadius),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppConfig.defaultPadding),
            child: child,
          ),
        ],
      ),
    );
  }
}
