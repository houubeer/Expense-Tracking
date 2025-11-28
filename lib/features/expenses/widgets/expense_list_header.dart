import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/app_routes.dart';

class ExpenseListHeader extends StatelessWidget {
  const ExpenseListHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transactions',
              style: AppTextStyles.heading1,
            ),
            const SizedBox(height: 8),
            Text(
              'View and manage your expense history',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => context.go(AppRoutes.addExpense),
          icon: const Icon(Icons.add, size: AppSpacing.iconXs),
          label: const Text("Add Expense"),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textInverse,
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
