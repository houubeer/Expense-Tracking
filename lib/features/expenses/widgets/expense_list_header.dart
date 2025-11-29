import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/app_routes.dart';
import '../../../widgets/buttons.dart';

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
              'View Expenses',
              style: AppTextStyles.heading1,
            ),
            const SizedBox(height: 8),
            Text(
              'View and manage your expense history',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
        PrimaryButton(
          onPressed: () => context.go(AppRoutes.addExpense),
          icon: Icons.add,
          child: const Text("Add Expense"),
        ),
      ],
    );
  }
}
