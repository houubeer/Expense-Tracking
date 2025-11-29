import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';
import 'package:expense_tracking_desktop_app/constants/app_routes.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: AppTextStyles.heading1,
            ),
            const SizedBox(height: 8),
            Text(
              'Overview of your financial health',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => context.go(AppRoutes.addExpense),
          icon: const Icon(Icons.add, size: AppSpacing.iconXs),
          label: Text(AppStrings.btnAddExpense),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xlMinor, vertical: AppSpacing.lg),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            textStyle: AppTextStyles.button,
          ),
        ),
      ],
    );
  }
}
