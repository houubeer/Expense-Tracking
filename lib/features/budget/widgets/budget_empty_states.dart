import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';

/// Empty state widget when no categories exist
class BudgetEmptyState extends StatelessWidget {
  const BudgetEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Text(
        AppStrings.descNoCategoriesFound,
        style: AppTextStyles.bodyLarge.copyWith(color: colorScheme.onSurfaceVariant),
      ),
    );
  }
}

/// No matches state widget when filters yield no results
class BudgetNoMatchesState extends StatelessWidget {
  const BudgetNoMatchesState({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.filter_list_off,
            size: 64,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            AppStrings.descNoMatchingCategories,
            style: AppTextStyles.bodyLarge.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
