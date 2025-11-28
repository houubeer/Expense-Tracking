import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/database/daos/expense_dao.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';
import 'package:expense_tracking_desktop_app/utils/icon_utils.dart';
import 'package:expense_tracking_desktop_app/features/expenses/widgets/expense_detail_dialog.dart';
import 'package:expense_tracking_desktop_app/features/expenses/widgets/edit_expense_dialog.dart';
import 'package:expense_tracking_desktop_app/providers/app_providers.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' as drift;
import 'package:expense_tracking_desktop_app/features/shared/widgets/common/success_snackbar.dart';

class ExpenseTable extends ConsumerWidget {
  final List<ExpenseWithCategory> expenses;

  const ExpenseTable({
    super.key,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No transactions found',
              style: AppTextStyles.heading3
                  .copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildTableHeader(),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: ListView.separated(
            itemCount: expenses.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1, color: AppColors.border),
            itemBuilder: (context, index) {
              final item = expenses[index];
              return _ExpenseRow(
                item: item,
                onTap: () => _showExpenseDetail(context, item),
                onEdit: () => _showEditDialog(context, ref, item),
                onDelete: () => _confirmDelete(context, ref, item),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child: Text(AppStrings.labelDate, style: AppTextStyles.label)),
          Expanded(
              flex: 2,
              child:
                  Text(AppStrings.labelCategory, style: AppTextStyles.label)),
          Expanded(
              flex: 3,
              child: Text(AppStrings.labelDescription,
                  style: AppTextStyles.label)),
          Expanded(
              flex: 2,
              child: Text(AppStrings.labelAmount, style: AppTextStyles.label)),
          const SizedBox(
              width: 100,
              child: Text('Actions',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary),
                  textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  void _showExpenseDetail(BuildContext context, ExpenseWithCategory item) {
    showDialog(
      context: context,
      builder: (context) => ExpenseDetailDialog(
        expenseWithCategory: item,
      ),
    );
  }

  void _showEditDialog(
      BuildContext context, WidgetRef ref, ExpenseWithCategory item) {
    final expenseService = ref.read(expenseServiceProvider);
    final categoryRepository = ref.read(categoryRepositoryProvider);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EditExpenseDialog(
        expenseService: expenseService,
        categoryRepository: categoryRepository,
        expenseWithCategory: item,
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, ExpenseWithCategory item) {
    final expenseService = ref.read(expenseServiceProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(AppStrings.titleDeleteTransaction,
            style: AppTextStyles.heading3),
        content: Text(AppStrings.descDeleteTransaction),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.btnCancel, style: AppTextStyles.bodyMedium),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await expenseService.deleteExpense(item.expense);

              if (context.mounted) {
                SuccessSnackbar.show(context, AppStrings.msgTransactionDeleted,
                    onUndo: () async {
                  final expense = ExpensesCompanion(
                    amount: drift.Value(item.expense.amount),
                    date: drift.Value(item.expense.date),
                    description: drift.Value(item.expense.description),
                    categoryId: drift.Value(item.expense.categoryId),
                    createdAt: drift.Value(item.expense.createdAt),
                  );
                  await expenseService.createExpense(expense);
                });
              }
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.red),
            child: Text(AppStrings.btnDelete),
          ),
        ],
      ),
    );
  }
}

class _ExpenseRow extends StatelessWidget {
  final ExpenseWithCategory item;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExpenseRow({
    required this.item,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = Color(item.category.color);
    final dateStr = DateFormat('MMM dd, yyyy').format(item.expense.date);

    return InkWell(
      onTap: onTap,
      hoverColor: AppColors.primary.withValues(alpha: 0.03),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                dateStr,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textPrimary),
              ),
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: 6),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.xl - 4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        IconUtils.fromCodePoint(item.category.iconCodePoint),
                        color: categoryColor,
                        size: AppSpacing.lg,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        item.category.name,
                        style: AppTextStyles.caption.copyWith(
                          color: categoryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                item.expense.description,
                style: AppTextStyles.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                "${item.expense.amount.toStringAsFixed(2)} ${AppStrings.currency}",
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            SizedBox(
              width: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        size: AppSpacing.iconSm, color: AppColors.primary),
                    onPressed: onEdit,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        size: AppSpacing.iconSm, color: AppColors.red),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
