import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';
import 'package:expense_tracking_desktop_app/constants/app_config.dart';
import 'package:expense_tracking_desktop_app/providers/app_providers.dart';
import 'package:intl/intl.dart';

class ExpenseFilters extends ConsumerWidget {
  final int? selectedCategoryId;
  final DateTime? selectedDate;
  final ValueChanged<int?> onCategoryChanged;
  final ValueChanged<DateTime?> onDateChanged;

  const ExpenseFilters({
    super.key,
    required this.selectedCategoryId,
    required this.selectedDate,
    required this.onCategoryChanged,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final categoryRepository = ref.watch(categoryRepositoryProvider);

    return Row(
      children: [
        // Category Filter
        Expanded(
          flex: 2,
          child: StreamBuilder<List<Category>>(
            stream: categoryRepository.watchAllCategories(),
            builder: (context, snapshot) {
              final categories = snapshot.data ?? [];
              return _buildCategoryDropdown(categories, colorScheme);
            },
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        // Date Filter
        Expanded(
          flex: 2,
          child: _buildDatePicker(context, colorScheme),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown(
      List<Category> categories, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
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
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: selectedCategoryId,
          hint: Row(
            children: [
              Icon(Icons.filter_list,
                  color: colorScheme.onSurfaceVariant,
                  size: AppSpacing.iconSm,
                  semanticLabel: 'Filter'),
              const SizedBox(width: AppSpacing.sm),
              Text(AppStrings.labelCategory, style: AppTextStyles.bodyMedium),
            ],
          ),
          isExpanded: true,
          items: [
            DropdownMenuItem<int?>(
              value: null,
              child: Row(
                children: [
                  Icon(Icons.category_outlined,
                      color: colorScheme.onSurfaceVariant,
                      size: AppSpacing.iconSm,
                      semanticLabel: 'All categories'),
                  const SizedBox(width: AppSpacing.sm),
                  const Text('All Categories'),
                ],
              ),
            ),
            ...categories.map((category) {
              return DropdownMenuItem<int?>(
                value: category.id,
                child: Row(
                  children: [
                    Container(
                      width: AppSpacing.md,
                      height: AppSpacing.md,
                      decoration: BoxDecoration(
                        color: Color(category.color),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(category.name),
                  ],
                ),
              );
            }),
          ],
          onChanged: onCategoryChanged,
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
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
      ),
      child: InkWell(
        onTap: () async {
          final DateTimeRange? picked = await showDateRangePicker(
            context: context,
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
            initialDateRange: selectedDate != null
                ? DateTimeRange(
                    start: selectedDate!,
                    end: selectedDate!,
                  )
                : null,
          );
          if (picked != null) {
            // For now, use the start date. You may want to extend your filter to support date ranges
            onDateChanged(picked.start);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: Row(
            children: [
              Icon(Icons.calendar_today,
                  color: colorScheme.onSurfaceVariant, size: AppSpacing.iconSm),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  selectedDate == null
                      ? AppStrings.labelDate
                      : DateFormat('MMM dd, yyyy').format(selectedDate!),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: selectedDate == null
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.onSurface,
                  ),
                ),
              ),
              if (selectedDate != null)
                GestureDetector(
                  onTap: () => onDateChanged(null),
                  child: Icon(Icons.close,
                      color: colorScheme.onSurfaceVariant,
                      size: AppSpacing.iconXs),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
