import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/app_config.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';
import 'package:expense_tracking_desktop_app/constants/app_routes.dart';
import 'package:expense_tracking_desktop_app/database/daos/expense_dao.dart';
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
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: _cardDecoration(),
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
                            const Divider(
                                height: AppSpacing.xl, color: AppColors.border),
                        ],
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: AppConfig.shadowBlurRadiusMd,
            offset: Offset(AppConfig.shadowOffsetX, AppConfig.shadowOffsetY),
          ),
        ],
      );
}
