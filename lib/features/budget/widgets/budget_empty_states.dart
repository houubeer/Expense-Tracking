import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';

/// Empty state widget when no categories exist
class BudgetEmptyState extends StatelessWidget {
  const BudgetEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        AppStrings.descNoCategoriesFound,
        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}

/// No matches state widget when filters yield no results
class BudgetNoMatchesState extends StatelessWidget {
  const BudgetNoMatchesState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.filter_list_off,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            AppStrings.descNoMatchingCategories,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
