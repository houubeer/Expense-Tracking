import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/app_config.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';
import 'package:expense_tracking_desktop_app/constants/app_routes.dart';
import 'package:expense_tracking_desktop_app/features/expenses/services/i_expense_service.dart';
import 'package:expense_tracking_desktop_app/features/shared/widgets/common/section_header.dart';
import 'package:expense_tracking_desktop_app/features/home/widgets/expense_list_item.dart';
import 'package:expense_tracking_desktop_app/utils/formatters/date_formatters.dart';

class RecentExpensesCard extends StatelessWidget {
  final List<ExpenseWithCategory> recentExpenses;

  const RecentExpensesCard({
    super.key,
    required this.recentExpenses,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: _cardDecoration(colorScheme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: AppStrings.titleRecentExpenses,
            actionText: AppStrings.navViewAll,
            onActionPressed: () => context.go(AppRoutes.viewExpenses),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Scrollable expenses list
          SizedBox(
            height: 300,
            child: recentExpenses.isEmpty
                ? Center(child: Text(AppStrings.msgNoExpensesYet))
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        for (int i = 0; i < recentExpenses.length; i++) ...[
                          ExpenseListItem(
                            title: DateFormatters.truncateDescription(
                                recentExpenses[i].expense.description),
                            category: recentExpenses[i].category.name,
                            date: DateFormatters.formatShortDate(
                                recentExpenses[i].expense.date),
                            amount: recentExpenses[i].expense.amount,
                            iconColor: Color(recentExpenses[i].category.color),
                          ),
                          if (i < recentExpenses.length - 1)
                            Divider(
                                height: AppSpacing.xl, color: Theme.of(context).colorScheme.outlineVariant),
                        ],
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration(ColorScheme colorScheme) => BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.05),
            blurRadius: AppConfig.shadowBlurRadiusMd,
            offset: Offset(AppConfig.shadowOffsetX, AppConfig.shadowOffsetY),
          ),
        ],
      );
}
