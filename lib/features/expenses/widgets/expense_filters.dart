import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/l10n/app_localizations.dart';
import 'package:expense_tracking_desktop_app/constants/app_config.dart';
import 'package:expense_tracking_desktop_app/providers/app_providers.dart';
import 'package:intl/intl.dart';

/// Filter option for reimbursable status
enum ReimbursableFilter {
  all,
  reimbursable,
  nonReimbursable,
}

class ExpenseFilters extends ConsumerWidget {
  const ExpenseFilters({
    super.key,
    required this.selectedCategoryId,
    this.selectedDate,
    this.startDate,
    this.endDate,
    this.reimbursableFilter = ReimbursableFilter.all,
    required this.onCategoryChanged,
    required this.onDateChanged,
    this.onDateRangeChanged,
    required this.onReimbursableFilterChanged,
  });
  
  final int? selectedCategoryId;
  final DateTime? selectedDate;
  final DateTime? startDate;
  final DateTime? endDate;
  final ReimbursableFilter reimbursableFilter;
  final ValueChanged<int?> onCategoryChanged;
  final ValueChanged<DateTime?> onDateChanged;
  final void Function(DateTime?, DateTime?)? onDateRangeChanged;
  final ValueChanged<ReimbursableFilter> onReimbursableFilterChanged;

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
              return _buildCategoryDropdown(context, categories, colorScheme);
            },
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        // Reimbursable Filter
        Expanded(
          flex: 2,
          child: _buildReimbursableFilter(context, colorScheme),
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

  Widget _buildReimbursableFilter(
      BuildContext context, ColorScheme colorScheme) {
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
        child: DropdownButton<ReimbursableFilter>(
          value: reimbursableFilter,
          isExpanded: true,
          items: [
            DropdownMenuItem(
              value: ReimbursableFilter.all,
              child: Row(
                children: [
                  Icon(
                    Icons.monetization_on_outlined,
                    color: colorScheme.onSurfaceVariant,
                    size: AppSpacing.iconSm,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(AppLocalizations.of(context)!.filterAll),
                ],
              ),
            ),
            DropdownMenuItem(
              value: ReimbursableFilter.reimbursable,
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: colorScheme.primary,
                    size: AppSpacing.iconSm,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(AppLocalizations.of(context)!.filterReimbursable),
                ],
              ),
            ),
            DropdownMenuItem(
              value: ReimbursableFilter.nonReimbursable,
              child: Row(
                children: [
                  Icon(
                    Icons.cancel_outlined,
                    color: colorScheme.onSurfaceVariant,
                    size: AppSpacing.iconSm,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(AppLocalizations.of(context)!.filterNonReimbursable),
                ],
              ),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              onReimbursableFilterChanged(value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(
    BuildContext context,
    List<Category> categories,
    ColorScheme colorScheme,
  ) {
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
              Icon(
                Icons.filter_list,
                color: colorScheme.onSurfaceVariant,
                size: AppSpacing.iconSm,
                semanticLabel: AppLocalizations.of(context)!.semanticFilter,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(AppLocalizations.of(context)!.labelCategory,
                  style: AppTextStyles.bodyMedium),
            ],
          ),
          isExpanded: true,
          items: [
            DropdownMenuItem<int?>(
              value: null,
              child: Row(
                children: [
                  Icon(
                    Icons.category_outlined,
                    color: colorScheme.onSurfaceVariant,
                    size: AppSpacing.iconSm,
                    semanticLabel:
                        AppLocalizations.of(context)!.semanticAllCategories,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(AppLocalizations.of(context)!.filterAllCategories),
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
    // Determine display values - prioritize date range over single date
    final displayStartDate = startDate ?? selectedDate;
    final displayEndDate = endDate ?? selectedDate;
    final hasDateFilter = displayStartDate != null || displayEndDate != null;

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
          // Show date range picker
          final DateTimeRange? pickedRange = await showDateRangePicker(
            context: context,
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
            initialDateRange: displayStartDate != null && displayEndDate != null
                ? DateTimeRange(start: displayStartDate, end: displayEndDate)
                : null,
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: colorScheme,
                ),
                child: child!,
              );
            },
          );

          if (pickedRange != null) {
            // Use date range callback if available, otherwise fall back to single date
            if (onDateRangeChanged != null) {
              onDateRangeChanged!(pickedRange.start, pickedRange.end);
            } else {
              // Backward compatibility: use start date only
              onDateChanged(pickedRange.start);
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: colorScheme.onSurfaceVariant,
                size: AppSpacing.iconSm,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  _getDateRangeText(context),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: hasDateFilter
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant,
                    fontSize: hasDateFilter ? 13 : 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (hasDateFilter)
                GestureDetector(
                  onTap: () => onDateChanged(null),
                  child: Icon(
                    Icons.close,
                    color: colorScheme.onSurfaceVariant,
                    size: AppSpacing.iconXs,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDateRangeText(BuildContext context) {
    final displayStartDate = startDate ?? selectedDate;
    final displayEndDate = endDate ?? selectedDate;

    if (displayStartDate == null && displayEndDate == null) {
      return AppLocalizations.of(context)!.labelDate;
    }

    if (displayStartDate != null && displayEndDate != null) {
      // Check if same day
      if (displayStartDate.year == displayEndDate.year &&
          displayStartDate.month == displayEndDate.month &&
          displayStartDate.day == displayEndDate.day) {
        return DateFormat('MMM dd, yyyy').format(displayStartDate);
      }
      // Different days - show range
      return '${DateFormat('MMM dd').format(displayStartDate)} - ${DateFormat('MMM dd, yyyy').format(displayEndDate)}';
    }

    if (displayStartDate != null) {
      return 'From ${DateFormat('MMM dd, yyyy').format(displayStartDate)}';
    }

    if (displayEndDate != null) {
      return 'Until ${DateFormat('MMM dd, yyyy').format(displayEndDate)}';
    }

    return AppLocalizations.of(context)!.labelDate;
  }
}
