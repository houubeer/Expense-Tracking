import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';
import 'package:expense_tracking_desktop_app/features/shared/widgets/cards/stat_card.dart';
import 'package:expense_tracking_desktop_app/features/home/providers/dashboard_provider.dart';
import 'package:expense_tracking_desktop_app/constants/app_config.dart';

class DashboardStatsGrid extends StatelessWidget {
  final DashboardState state;

  const DashboardStatsGrid({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isDesktop = width > AppConfig.desktopBreakpoint;
        final cardWidth = isDesktop ? (width - 60) / 4 : (width - 20) / 2;

        return Wrap(
          spacing: AppSpacing.xlMinor,
          runSpacing: AppSpacing.xlMinor,
          children: [
            StatCard(
              title: "Total Balance",
              value:
                  "${state.totalBalance.toStringAsFixed(0)} ${AppStrings.currency}",
              trend: state.balanceTrend,
              icon: Icons.account_balance_wallet_outlined,
              color: state.balanceColor,
              width: cardWidth,
            ),
            StatCard(
              title: "Number of Categories",
              value: "${state.activeCategories} Active",
              trend: state.categoriesTrend,
              icon: Icons.category_outlined,
              color: AppColors.purple,
              width: cardWidth,
            ),
            StatCard(
              title: "Expenses",
              value:
                  "${state.totalExpenses.toStringAsFixed(0)} ${AppStrings.currency}",
              trend: state.expenseTrend,
              icon: Icons.arrow_downward_rounded,
              color: AppColors.red,
              width: cardWidth,
            ),
            StatCard(
              title: "Daily Avg Spending",
              value:
                  "${state.dailyAverage.toStringAsFixed(0)} ${AppStrings.currency}",
              trend: state.dailyAverageTrend,
              icon: Icons.trending_down_rounded,
              color: AppColors.teal,
              width: cardWidth,
            ),
          ],
        );
      },
    );
  }
}
