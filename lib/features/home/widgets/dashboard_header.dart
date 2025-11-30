import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';
import 'package:expense_tracking_desktop_app/constants/app_routes.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import '../../../widgets/buttons.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
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
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Overview of your financial health',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
        PrimaryButton(
          onPressed: () => context.go(AppRoutes.addExpense),
          icon: Icons.add,
          child: const Text(AppStrings.btnAddExpense),
        ),
      ],
    );
  }
}
