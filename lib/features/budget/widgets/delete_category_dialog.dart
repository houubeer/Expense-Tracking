import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';

/// Confirmation dialog for deleting a category
class DeleteCategoryDialog extends StatelessWidget {
  final Category category;
  final VoidCallback onConfirm;

  const DeleteCategoryDialog({
    super.key,
    required this.category,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(
        AppStrings.titleDeleteCategory,
        style: AppTextStyles.heading3,
      ),
      content: Text(
        AppStrings.descDeleteCategory.replaceAll('{name}', category.name),
        style: AppTextStyles.bodyMedium,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppStrings.btnCancel, style: AppTextStyles.bodyMedium),
        ),
        FilledButton(
          onPressed: () {
            onConfirm();
            Navigator.pop(context);
          },
          style: FilledButton.styleFrom(backgroundColor: AppColors.red),
          child: const Text(AppStrings.btnDelete),
        ),
      ],
    );
  }
}
