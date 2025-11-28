import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';

class SuccessSnackbar extends SnackBar {
  SuccessSnackbar({
    super.key,
    required String message,
    VoidCallback? onUndo,
  }) : super(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.textInverse),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.snackbarText,
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          action: onUndo != null
              ? SnackBarAction(
                  label: 'UNDO',
                  textColor: Colors.white,
                  onPressed: onUndo,
                )
              : null,
        );

  static void show(BuildContext context, String message,
      {VoidCallback? onUndo}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SuccessSnackbar(message: message, onUndo: onUndo),
    );
  }
}
