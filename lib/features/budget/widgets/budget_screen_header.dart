import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';

/// Header widget for Budget Setting Screen
/// Separated for better modularity and reusability
class BudgetScreenHeader extends StatelessWidget {

  const BudgetScreenHeader({
    required this.onAddPressed, super.key,
  });
  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.titleBudgetManagement,
              style: AppTextStyles.heading1,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              AppStrings.descManageBudgets,
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
        FilledButton.icon(
          onPressed: onAddPressed,
          icon: const Icon(Icons.add, size: AppSpacing.iconXs),
          label: const Text(AppStrings.btnAddCategory),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl - 4,
              vertical: AppSpacing.lg,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
          ),
        ),
      ],
    );
  }
}
