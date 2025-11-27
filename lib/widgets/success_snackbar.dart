import 'package:flutter/material.dart';
import '../constants/colors.dart';

class SuccessSnackbar extends SnackBar {
  SuccessSnackbar({
    super.key,
    required String message,
    VoidCallback? onUndo,
  }) : super(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
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
