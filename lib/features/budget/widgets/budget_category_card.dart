import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';
import 'package:expense_tracking_desktop_app/constants/app_config.dart';
import 'package:expense_tracking_desktop_app/constants/app_routes.dart';
import 'package:expense_tracking_desktop_app/utils/budget_status_calculator.dart';
import 'package:expense_tracking_desktop_app/utils/icon_utils.dart';
import 'package:expense_tracking_desktop_app/widgets/animations/animated_widgets.dart';

/// Card widget displaying a budget category with its details and actions
class BudgetCategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BudgetCategoryCard({
    super.key,
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconData = IconUtils.fromCodePoint(category.iconCodePoint);
    final categoryColor = Color(category.color);

    return AnimatedHoverCard(
      scale: 1.01,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: Border.all(color: colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.05),
              blurRadius: AppConfig.shadowBlurRadius,
              offset: Offset(AppConfig.shadowOffsetX, AppConfig.shadowOffsetY),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, iconData, categoryColor),
            const SizedBox(height: AppSpacing.xl),
            _buildProgressBar(),
            const SizedBox(height: AppSpacing.lg),
            _buildStatsRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    IconData iconData,
    Color categoryColor,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: categoryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: Icon(
            iconData,
            color: categoryColor,
            size: AppSpacing.iconLg,
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category.name,
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${AppStrings.labelMonthlyBudget}: ${category.budget.toStringAsFixed(2)} ${AppStrings.currency}',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
        Row(
          children: [
            FilledButton.icon(
              onPressed: () => context.go(AppRoutes.addExpense),
              icon: const Icon(Icons.add, size: AppSpacing.iconXs),
              label: Text(AppStrings.btnAddExpense),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit, size: AppSpacing.iconXs),
              label: Text(AppStrings.btnEdit),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, size: AppSpacing.iconSm),
              color: colorScheme.error,
              tooltip: 'Delete Category',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        final percentage = BudgetStatusCalculator.calculatePercentage(
          category.spent,
          category.budget,
        );
        final statusColor = BudgetStatusCalculator.getStatusColor(percentage);

        return Stack(
          children: [
            Container(
              height: 24,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: percentage.clamp(0.0, 1.0),
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  minHeight: 24,
                ),
              ),
            ),
            Positioned.fill(
              child: Center(
                child: Text(
                  '${(percentage * 100).toStringAsFixed(1)}%',
                  style: AppTextStyles.progressPercentage.copyWith(
                    color:
                        percentage > 0.5 ? Colors.white : colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsRow() {
    final percentage = BudgetStatusCalculator.calculatePercentage(
      category.spent,
      category.budget,
    );
    final remaining = category.budget - category.spent;
    final status = BudgetStatusCalculator.getStatusText(percentage);
    final statusColor = BudgetStatusCalculator.getStatusColor(percentage);
    final statusIcon = BudgetStatusCalculator.getStatusIcon(percentage);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.labelSpent,
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${category.spent.toStringAsFixed(2)} ${AppStrings.currency}',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.labelRemaining,
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${remaining.toStringAsFixed(2)} ${AppStrings.currency}',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Icon(
                statusIcon,
                color: statusColor,
                size: AppSpacing.iconXs,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                status,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
