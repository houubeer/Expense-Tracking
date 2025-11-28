import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';
import 'package:expense_tracking_desktop_app/constants/app_config.dart';
import 'package:expense_tracking_desktop_app/features/budget/view_models/budget_view_model.dart';
import 'package:expense_tracking_desktop_app/utils/budget_status_calculator.dart';

/// Controls bar for budget filtering and searching
class BudgetControlsBar extends ConsumerWidget {
  const BudgetControlsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(budgetFilterProvider);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl - 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: AppConfig.shadowBlurRadiusMd,
            offset: Offset(AppConfig.shadowOffsetX, AppConfig.shadowOffsetY),
          ),
        ],
      ),
      child: Row(
        children: [
          // Search field
          Expanded(
            flex: 2,
            child: _buildSearchField(context, ref, filter),
          ),
          const SizedBox(width: AppSpacing.lg),
          // Filter dropdown
          Expanded(
            child: _buildStatusFilter(ref, filter),
          ),
          const SizedBox(width: AppSpacing.lg),
          // Sort dropdown
          Expanded(
            child: _buildSortDropdown(ref, filter),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(
    BuildContext context,
    WidgetRef ref,
    BudgetFilter filter,
  ) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(
          color: filter.searchQuery.isNotEmpty
              ? AppColors.primary
              : AppColors.border,
          width: 1,
        ),
      ),
      child: TextField(
        onChanged: (value) {
          ref.read(budgetFilterProvider.notifier).state =
              filter.copyWith(searchQuery: value);
        },
        decoration: InputDecoration(
          hintText: AppStrings.hintSearchCategories,
          hintStyle: AppTextStyles.bodyMedium,
          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
          suffixIcon: filter.searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: AppColors.textSecondary),
                  onPressed: () {
                    ref.read(budgetFilterProvider.notifier).state =
                        filter.copyWith(searchQuery: '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl - 4,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFilter(WidgetRef ref, BudgetFilter filter) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: filter.statusFilter,
          isExpanded: true,
          icon: const Icon(Icons.filter_list),
          dropdownColor: AppColors.surface,
          items: [
            AppStrings.filterAll,
            AppStrings.statusGood,
            AppStrings.statusWarning,
            AppStrings.statusInRisk,
          ].map((status) {
            return DropdownMenuItem(
              value: status,
              child: Row(
                children: [
                  Icon(
                    BudgetStatusCalculator.getFilterIcon(status),
                    size: AppSpacing.iconXs,
                    color: BudgetStatusCalculator.getFilterColor(status),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(status, style: AppTextStyles.bodyMedium),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            ref.read(budgetFilterProvider.notifier).state =
                filter.copyWith(statusFilter: value!);
          },
        ),
      ),
    );
  }

  Widget _buildSortDropdown(WidgetRef ref, BudgetFilter filter) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: filter.sortBy,
          isExpanded: true,
          icon: const Icon(Icons.sort),
          dropdownColor: AppColors.surface,
          items: [
            AppStrings.filterSortByName,
            AppStrings.filterSortByBudget,
            AppStrings.filterSortBySpent,
            AppStrings.filterSortByPercentage,
          ].map((sort) {
            return DropdownMenuItem(
              value: sort,
              child: Text(
                'Sort: $sort',
                style: AppTextStyles.bodyMedium,
              ),
            );
          }).toList(),
          onChanged: (value) {
            ref.read(budgetFilterProvider.notifier).state =
                filter.copyWith(sortBy: value!);
          },
        ),
      ),
    );
  }
}
