import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: _cardDecoration(colorScheme),
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
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xxxl),
          child: Text(AppStrings.msgNoBudgetsYet),
        ),
      );
    }

    // Filter only categories with budgets
    final activeBudgets = budgetData.where((b) => !b.hasNoBudget).toList();

    if (activeBudgets.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xxxl),
          child: Text(AppStrings.msgNoBudgetsYet),
        ),
      );
    }

    // Sort by total spent (descending) to show top spenders first
    activeBudgets.sort((a, b) => b.totalSpent.compareTo(a.totalSpent));

    // Take top 4 categories with spending for pie chart
    const maxPieSlices = 4;
    final topBudgets = activeBudgets.take(maxPieSlices).toList();
    final otherBudgets = activeBudgets.skip(maxPieSlices).toList();

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

    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
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
                          color: colorScheme.onSurfaceVariant,
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
                              color: Colors.grey,
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
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _BudgetLegendItem(budgetView: budgetView),
                        );
                      }),
                      // Others section
                      if (otherBudgets.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
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
      },
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
            offset:
                const Offset(AppConfig.shadowOffsetX, AppConfig.shadowOffsetY),
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
    final colorScheme = Theme.of(context).colorScheme;

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
                color: color.withAlpha(77),
                blurRadius: AppConfig.shadowBlurRadiusSm,
                offset: const Offset(
                    AppConfig.shadowOffsetX, AppConfig.shadowOffsetY),
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
                      color: colorScheme.onSurface,
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
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  color: color,
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${budgetView.totalSpent.toStringAsFixed(0)} / ${budgetView.category.budget.toStringAsFixed(0)} ${AppStrings.currency}',
                style: AppTextStyles.caption.copyWith(
                  color: colorScheme.onSurfaceVariant,
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
    final colorScheme = Theme.of(context).colorScheme;
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
                color: Colors.grey,
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
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      color: Colors.grey,
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${othersSpent.toStringAsFixed(0)} / ${othersTotal.toStringAsFixed(0)} ${AppStrings.currency}',
                    style: AppTextStyles.caption.copyWith(
                      color: colorScheme.onSurfaceVariant,
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
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
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
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    Text(
                      '${budget.percentageUsed.toStringAsFixed(0)}%',
                      style: AppTextStyles.caption.copyWith(
                        color: colorScheme.onSurfaceVariant,
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
