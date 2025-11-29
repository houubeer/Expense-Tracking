import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';

class SuccessSnackbar extends SnackBar {
  SuccessSnackbar({
    super.key,
    required String message,
    required Color backgroundColor,
    required Color iconColor,
    VoidCallback? onUndo,
  }) : super(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: iconColor),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.snackbarText,
                ),
              ),
            ],
          ),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          action: onUndo != null
              ? SnackBarAction(
                  label: AppStrings.btnUndo,
                  textColor: Colors.white,
                  onPressed: onUndo,
                )
              : null,
        );

  static void show(BuildContext context, String message,
      {VoidCallback? onUndo}) {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SuccessSnackbar(
        message: message,
        backgroundColor: colorScheme.tertiary,
        iconColor: colorScheme.onTertiary,
        onUndo: onUndo,
      ),
    );
  }
}
