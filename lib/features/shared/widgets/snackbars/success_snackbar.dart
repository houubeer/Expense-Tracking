import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';

/// A reusable success snackbar widget with optional undo functionality
class SuccessSnackbar {
  /// Show a success snackbar with an optional undo action
  static void show(
    BuildContext context,
    String message, {
    VoidCallback? onUndo,
    Duration duration = const Duration(seconds: 3),
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: colorScheme.onSecondary,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.onSecondary,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        action: onUndo != null
            ? SnackBarAction(
                label: 'Undo',
                textColor: Colors.white,
                onPressed: onUndo,
              )
            : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
