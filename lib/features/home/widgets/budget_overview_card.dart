import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';
import 'package:expense_tracking_desktop_app/constants/app_config.dart';
import 'package:expense_tracking_desktop_app/constants/app_routes.dart';
import 'package:expense_tracking_desktop_app/features/budget/models/category_budget_view.dart';
import 'package:expense_tracking_desktop_app/features/shared/widgets/common/section_header.dart';
import 'package:fl_chart/fl_chart.dart';

class BudgetOverviewCard extends StatelessWidget {
  final List<CategoryBudgetView> budgetData;
  final int itemsToShow;

  const BudgetOverviewCard({
    super.key,
    required this.budgetData,
    this.itemsToShow = 5, // Default to 5, but can be changed
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
            title: AppStrings.titleBudgetOverview,
            actionText: AppStrings.navManageBudgets,
            onActionPressed: () => context.go(AppRoutes.budgets),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildBudgetContent(),
        ],
      ),
    );
  }

  Widget _buildBudgetContent() {
    if (budgetData.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxxl),
          child: Text(AppStrings.msgNoBudgetsYet),
        ),
      );
    }

    // Filter only categories with budgets
    final activeBudgets = budgetData.where((b) => !b.hasNoBudget).toList();

    if (activeBudgets.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxxl),
          child: Text(AppStrings.msgNoBudgetsYet),
        ),
      );
    }

    // Take top N and group others (configurable limit)
    final topBudgets = activeBudgets.take(itemsToShow).toList();
    final otherBudgets = activeBudgets.skip(itemsToShow).toList();

    // Prepare pie chart data - only categories with expenses
    final pieChartData = topBudgets.where((b) => b.totalSpent > 0).toList();

    // Calculate "Others" total - only if they have expenses
    double othersSpent = 0;
    double othersTotal = 0;
    for (var budget in otherBudgets) {
      if (budget.totalSpent > 0) {
        othersSpent += budget.totalSpent;
      }
      othersTotal += budget.category.budget;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pie Chart - Expenses Only
        SizedBox(
          height: 220,
          width: 220,
          child: pieChartData.isEmpty && othersSpent == 0
              ? Center(
                  child: Text(
                    AppStrings.msgNoExpensesYet,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              : PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 75,
                    sections: [
                      ...pieChartData.map((budgetView) {
                        return PieChartSectionData(
                          color: Color(budgetView.category.color),
                          value: budgetView.totalSpent,
                          title: '',
                          radius: 22,
                        );
                      }),
                      if (othersSpent > 0)
                        PieChartSectionData(
                          color: AppColors.textTertiary,
                          value: othersSpent,
                          title: '',
                          radius: 22,
                        ),
                    ],
                  ),
                ),
        ),
        const SizedBox(width: AppSpacing.xxl),
        // Scrollable Legend
        Expanded(
          child: SizedBox(
            height: 220,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Top N budgets (configurable)
                  ...topBudgets.map((budgetView) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _BudgetLegendItem(budgetView: budgetView),
                    );
                  }),
                  // Others section
                  if (otherBudgets.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _OthersLegendItem(
                        otherBudgets: otherBudgets,
                        othersSpent: othersSpent,
                        othersTotal: othersTotal,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
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

class _BudgetLegendItem extends StatelessWidget {
  final CategoryBudgetView budgetView;

  const _BudgetLegendItem({required this.budgetView});

  @override
  Widget build(BuildContext context) {
    final color = Color(budgetView.category.color);

    return Row(
      children: [
        Container(
          width: AppSpacing.md,
          height: AppSpacing.md,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: AppConfig.shadowBlurRadiusSm,
                offset:
                    Offset(AppConfig.shadowOffsetX, AppConfig.shadowOffsetY),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    budgetView.category.name,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${budgetView.percentageUsed.toStringAsFixed(1)}%',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                child: LinearProgressIndicator(
                  value: budgetView.percentageUsed / 100,
                  backgroundColor: AppColors.surfaceAlt,
                  color: color,
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${budgetView.totalSpent.toStringAsFixed(0)} / ${budgetView.category.budget.toStringAsFixed(0)} ${AppStrings.currency}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OthersLegendItem extends StatelessWidget {
  final List<CategoryBudgetView> otherBudgets;
  final double othersSpent;
  final double othersTotal;

  const _OthersLegendItem({
    required this.otherBudgets,
    required this.othersSpent,
    required this.othersTotal,
  });

  @override
  Widget build(BuildContext context) {
    final percentage =
        othersTotal > 0 ? (othersSpent / othersTotal * 100) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: AppSpacing.md,
              height: AppSpacing.md,
              decoration: const BoxDecoration(
                color: AppColors.textTertiary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Others (${otherBudgets.length})',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: AppColors.surfaceAlt,
                      color: AppColors.textTertiary,
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${othersSpent.toStringAsFixed(0)} / ${othersTotal.toStringAsFixed(0)} ${AppStrings.currency}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        // Show breakdown
        Padding(
          padding:
              const EdgeInsets.only(left: AppSpacing.xl, top: AppSpacing.sm),
          child: Column(
            children: otherBudgets.map((budget) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Color(budget.category.color),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        budget.category.name,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    Text(
                      '${budget.percentageUsed.toStringAsFixed(0)}%',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
