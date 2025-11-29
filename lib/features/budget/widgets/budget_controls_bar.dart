import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final colorScheme = Theme.of(context).colorScheme;
    final filter = ref.watch(budgetFilterProvider);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl - 4),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.05),
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
            child: _buildSearchField(context, ref, filter, colorScheme),
          ),
          const SizedBox(width: AppSpacing.lg),
          // Filter dropdown
          Expanded(
            child: _buildStatusFilter(ref, filter, colorScheme),
          ),
          const SizedBox(width: AppSpacing.lg),
          // Sort dropdown
          Expanded(
            child: _buildSortDropdown(ref, filter, colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(
    BuildContext context,
    WidgetRef ref,
    BudgetFilter filter,
    ColorScheme colorScheme,
  ) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(
          color: filter.searchQuery.isNotEmpty
              ? colorScheme.primary
              : colorScheme.outlineVariant,
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
          prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant, semanticLabel: 'Search'),
          suffixIcon: filter.searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: colorScheme.onSurfaceVariant, semanticLabel: 'Clear search'),
                  onPressed: () {
                    ref.read(budgetFilterProvider.notifier).state =
                        filter.copyWith(searchQuery: '');
                  },
                  tooltip: 'Clear search',
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

  Widget _buildStatusFilter(
      WidgetRef ref, BudgetFilter filter, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: filter.statusFilter,
          isExpanded: true,
          icon: const Icon(Icons.filter_list),
          dropdownColor: colorScheme.surface,
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

  Widget _buildSortDropdown(
      WidgetRef ref, BudgetFilter filter, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: filter.sortBy,
          isExpanded: true,
          icon: const Icon(Icons.sort),
          dropdownColor: colorScheme.surface,
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
