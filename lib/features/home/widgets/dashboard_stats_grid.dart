import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';
import 'package:expense_tracking_desktop_app/features/shared/widgets/cards/stat_card.dart';
import 'package:expense_tracking_desktop_app/features/home/providers/dashboard_provider.dart';
import 'package:expense_tracking_desktop_app/constants/app_config.dart';
import 'package:expense_tracking_desktop_app/l10n/app_localizations.dart';

class DashboardStatsGrid extends StatelessWidget {

  const DashboardStatsGrid({
    required this.state, super.key,
  });
  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final localizations = AppLocalizations.of(context)!;
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
              title: localizations.totalBalance,
              value:
                  '${state.totalBalance.toStringAsFixed(0)} ${AppStrings.currency}',
              trend: state.balanceTrend,
              icon: Icons.account_balance_wallet_outlined,
              color: state.balanceColor,
              width: cardWidth,
            ),
            StatCard(
              title: localizations.numberofCategories,
              value: '${state.activeCategories} ${localizations.active}',
              trend: state.categoriesTrend,
              icon: Icons.category_outlined,
              color: colorScheme.secondary,
              width: cardWidth,
            ),
            StatCard(
              title: localizations.expenses,
              value:
                  '${state.totalExpenses.toStringAsFixed(0)} ${AppStrings.currency}',
              trend: state.expenseTrend,
              icon: Icons.arrow_downward_rounded,
              color: colorScheme.error,
              width: cardWidth,
            ),
            StatCard(
              title: localizations.dailyAvgSpending,
              value:
                  '${state.dailyAverage.toStringAsFixed(0)} ${AppStrings.currency}',
              trend: state.dailyAverageTrend,
              icon: Icons.trending_down_rounded,
              color: colorScheme.tertiary,
              width: cardWidth,
            ),
          ],
        );
      },
    );
  }
}

