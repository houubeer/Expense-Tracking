import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/app_routes.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/widgets/buttons.dart';
import 'package:expense_tracking_desktop_app/l10n/app_localizations.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.dashboard,
              style: AppTextStyles.heading1,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              localizations.dashboardSubtitle,
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
        PrimaryButton(
          onPressed: () => context.go(AppRoutes.addExpense),
          icon: Icons.add,
          child: Text(localizations.addExpense),
        ),
      ],
    );
  }
}

