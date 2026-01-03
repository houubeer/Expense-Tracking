import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/app_routes.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/widgets/buttons.dart';

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
              AppLocalizations.of(context)!.titleViewExpenses,
              style: AppTextStyles.heading1,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              AppLocalizations.of(context)!.subtitleViewExpenses,
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
        PrimaryButton(
          onPressed: () => context.go(AppRoutes.addExpense),
          icon: Icons.add,
          child: Text(AppLocalizations.of(context)!.btnAddExpense),
        ),
      ],
    );
  }
}
