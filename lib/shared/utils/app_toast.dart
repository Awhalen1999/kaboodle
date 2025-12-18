import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

/// Centralized toast utility for consistent, theme-aware notifications
///
/// Usage:
/// - AppToast.success(context, 'Profile updated')
/// - AppToast.error(context, 'Failed to save')
/// - AppToast.info(context, 'No purchases found')
///
/// Only use toasts for:
/// - Success feedback (save, delete, update confirmations)
/// - Errors that need user attention
/// - Informational messages the user should see
class AppToast {
  AppToast._();

  static const Duration _defaultDuration = Duration(seconds: 3);

  /// Show a success toast
  static void success(BuildContext context, String message) {
    _show(
      context: context,
      message: message,
      type: ToastificationType.success,
    );
  }

  /// Show an error toast
  static void error(BuildContext context, String message) {
    _show(
      context: context,
      message: message,
      type: ToastificationType.error,
    );
  }

  /// Show an info toast
  static void info(BuildContext context, String message) {
    _show(
      context: context,
      message: message,
      type: ToastificationType.info,
    );
  }

  static void _show({
    required BuildContext context,
    required String message,
    required ToastificationType type,
  }) {
    if (!context.mounted) return;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    toastification.show(
      context: context,
      type: type,
      style: ToastificationStyle.flat,
      title: Text(
        message,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
      autoCloseDuration: _defaultDuration,
      alignment: Alignment.topCenter,
      backgroundColor: colorScheme.surfaceContainerHighest,
      foregroundColor: colorScheme.onSurface,
      primaryColor: _getPrimaryColor(type, colorScheme),
      showProgressBar: false,
      borderSide: BorderSide(color: colorScheme.outline),
      borderRadius: BorderRadius.circular(12),
    );
  }

  static Color _getPrimaryColor(
    ToastificationType type,
    ColorScheme colorScheme,
  ) {
    return switch (type) {
      ToastificationType.success => Colors.green,
      ToastificationType.error => colorScheme.error,
      ToastificationType.info => colorScheme.primary,
      _ => colorScheme.primary,
    };
  }
}
