import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/features/expenses/services/i_expense_service.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';
import 'package:intl/intl.dart';

class ExpenseDetailDialog extends StatelessWidget {
  final ExpenseWithCategory expenseWithCategory;

  const ExpenseDetailDialog({
    required this.expenseWithCategory,
    super.key,
  });

  IconData _getIconFromCodePoint(String codePointStr) {
    try {
      final codePoint = int.parse(codePointStr);
      return IconData(codePoint, fontFamily: 'MaterialIcons');
    } catch (e) {
      return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final expense = expenseWithCategory.expense;
    final category = expenseWithCategory.category;
    final categoryColor = Color(category.color);
    final dateStr = DateFormat('EEEE, MMMM dd, yyyy').format(expense.date);

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusLg),
                      ),
                      child: Icon(
                        _getIconFromCodePoint(category.iconCodePoint),
                        color: categoryColor,
                        size: AppSpacing.xxl,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Expense Details',
                            style: AppTextStyles.heading3,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            category.name,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: categoryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                const Divider(color: AppColors.border),
                const SizedBox(height: AppSpacing.xl),

                // Amount
                _buildDetailRow(
                  AppStrings.labelAmount,
                  '${expense.amount.toStringAsFixed(2)} ${AppStrings.currency}',
                  Icons.attach_money,
                  AppColors.green,
                ),
                const SizedBox(height: AppSpacing.xl - 4),

                // Date
                _buildDetailRow(
                  AppStrings.labelDate,
                  dateStr,
                  Icons.calendar_today,
                  AppColors.accent,
                ),
                const SizedBox(height: AppSpacing.xl - 4),

                // Description
                _buildDetailRow(
                  AppStrings.labelDescription,
                  expense.description,
                  Icons.description,
                  AppColors.purple,
                ),
                const SizedBox(height: AppSpacing.xl),

                // Budget Info
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Category Budget',
                        style: AppTextStyles.label,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.labelBudget,
                                style: AppTextStyles.caption,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                '${category.budget.toStringAsFixed(2)} ${AppStrings.currency}',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Column(
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
                                  color: categoryColor,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.labelRemaining,
                                style: AppTextStyles.caption,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                '${(category.budget - category.spent).toStringAsFixed(2)} ${AppStrings.currency}',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Close Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusLg),
                      ),
                    ),
                    child:
                        Text(AppStrings.btnClose, style: AppTextStyles.button),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Icon(icon, color: iconColor, size: AppSpacing.iconSm),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                value,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
// habltni software eng
