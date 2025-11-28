import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
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
              return _buildCategoryDropdown(categories);
            },
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        // Date Filter
        Expanded(
          flex: 2,
          child: _buildDatePicker(context),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown(List<Category> categories) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: AppConfig.shadowBlurRadiusMd,
            offset: const Offset(
                AppConfig.shadowOffsetX, AppConfig.shadowOffsetY),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: selectedCategoryId,
          hint: Row(
            children: [
              Icon(Icons.filter_list,
                  color: AppColors.textSecondary, size: AppSpacing.iconSm),
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
                  Icon(Icons.clear,
                      color: AppColors.textSecondary, size: AppSpacing.iconSm),
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

  Widget _buildDatePicker(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: AppConfig.shadowBlurRadiusMd,
            offset: const Offset(
                AppConfig.shadowOffsetX, AppConfig.shadowOffsetY),
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
              Icon(Icons.calendar_today,
                  color: AppColors.textSecondary, size: AppSpacing.iconSm),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  selectedDate == null
                      ? AppStrings.labelDate
                      : DateFormat('MMM dd, yyyy').format(selectedDate!),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: selectedDate == null
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              if (selectedDate != null)
                GestureDetector(
                  onTap: () => onDateChanged(null),
                  child: Icon(Icons.close,
                      color: AppColors.textSecondary, size: AppSpacing.iconXs),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
