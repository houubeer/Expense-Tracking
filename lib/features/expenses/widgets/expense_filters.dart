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
    required this.selectedCategoryId,
    required this.selectedDate,
    required this.onCategoryChanged,
    required this.onDateChanged,
    required this.onReimbursableFilterChanged,
    super.key,
    this.reimbursableFilter = ReimbursableFilter.all,
  });
  final int? selectedCategoryId;
  final DateTime? selectedDate;
  final ReimbursableFilter reimbursableFilter;
  final ValueChanged<int?> onCategoryChanged;
  final ValueChanged<DateTime?> onDateChanged;
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
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: selectedDate ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
          );
          if (picked != null) {
            onDateChanged(picked);
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
                  selectedDate == null
                      ? AppLocalizations.of(context)!.labelDate
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
}
