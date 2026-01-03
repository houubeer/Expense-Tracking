import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/features/expenses/services/i_expense_service.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/l10n/app_localizations.dart';
import 'package:expense_tracking_desktop_app/utils/icon_utils.dart';
import 'package:expense_tracking_desktop_app/features/expenses/widgets/expense_detail_dialog.dart';
import 'package:expense_tracking_desktop_app/features/expenses/widgets/edit_expense_dialog.dart';
import 'package:expense_tracking_desktop_app/providers/app_providers.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' as drift;
import 'package:expense_tracking_desktop_app/features/shared/widgets/common/success_snackbar.dart';

class ExpenseTable extends ConsumerWidget {
  const ExpenseTable({
    required this.expenses,
    super.key,
  });
  final List<ExpenseWithCategory> expenses;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    if (expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant.withAlpha(128),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              AppLocalizations.of(context)!.titleNoExpenses,
              style: AppTextStyles.heading3
                  .copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildTableHeader(context, colorScheme),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: ListView.separated(
            itemCount: expenses.length,
            separatorBuilder: (context, index) =>
                Divider(height: 1, color: colorScheme.outlineVariant),
            itemBuilder: (context, index) {
              final item = expenses[index];
              return _ExpenseRow(
                item: item,
                onTap: () => _showExpenseDetail(context, item),
                onEdit: () => _showEditDialog(context, ref, item),
                onDelete: () => _confirmDelete(context, ref, item, colorScheme),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(AppLocalizations.of(context)!.labelDate,
                style: AppTextStyles.label),
          ),
          Expanded(
            flex: 2,
            child: Text(AppLocalizations.of(context)!.labelCategory,
                style: AppTextStyles.label),
          ),
          Expanded(
            flex: 3,
            child: Text(
              AppLocalizations.of(context)!.labelDescription,
              style: AppTextStyles.label,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(AppLocalizations.of(context)!.labelAmount,
                style: AppTextStyles.label),
          ),
          SizedBox(
            width: 100,
            child: Text(
              AppLocalizations.of(context)!.colActions,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  void _showExpenseDetail(BuildContext context, ExpenseWithCategory item) {
    showDialog<void>(
      context: context,
      builder: (context) => ExpenseDetailDialog(
        expenseWithCategory: item,
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    ExpenseWithCategory item,
  ) {
    final expenseService = ref.read(expenseServiceProvider);
    final categoryRepository = ref.read(categoryRepositoryProvider);

    showDialog<void>(
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
    BuildContext context,
    WidgetRef ref,
    ExpenseWithCategory item,
    ColorScheme colorScheme,
  ) {
    final expenseService = ref.read(expenseServiceProvider);

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text(
          AppLocalizations.of(context)!.titleDeleteTransaction,
          style: AppTextStyles.heading3,
        ),
        content: Text(AppLocalizations.of(context)!.descDeleteTransaction),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.btnCancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await expenseService.deleteExpense(item.expense);

                if (context.mounted) {
                  SuccessSnackbar.show(
                    context,
                    AppLocalizations.of(context)!.msgTransactionDeleted,
                    onUndo: () async {
                      try {
                        final expense = ExpensesCompanion(
                          amount: drift.Value(item.expense.amount),
                          date: drift.Value(item.expense.date),
                          description: drift.Value(item.expense.description),
                          categoryId: drift.Value(item.expense.categoryId),
                          createdAt: drift.Value(item.expense.createdAt),
                        );
                        await expenseService.createExpense(expense);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.of(context)!
                                    .errRestoreExpense(e.toString()),
                              ),
                              backgroundColor: colorScheme.error,
                            ),
                          );
                        }
                      }
                    },
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!
                          .errDeleteExpense(e.toString())),
                      backgroundColor: colorScheme.error,
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
            child: Text(AppLocalizations.of(context)!.btnDelete),
          ),
        ],
      ),
    );
  }
}

class _ExpenseRow extends StatelessWidget {
  const _ExpenseRow({
    required this.item,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });
  final ExpenseWithCategory item;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final categoryColor = Color(item.category.color);
    final dateStr = DateFormat('MMM dd, yyyy').format(item.expense.date);

    return InkWell(
      onTap: onTap,
      hoverColor: colorScheme.primary.withValues(alpha: 0.03),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                dateStr,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: colorScheme.onSurface),
              ),
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 6,
                  ),
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
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.expense.description,
                      style: AppTextStyles.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (item.expense.isReimbursable) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppSpacing.xs),
                        border: Border.all(
                          color: colorScheme.tertiary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.monetization_on_outlined,
                            size: 12,
                            color: colorScheme.tertiary,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            AppLocalizations.of(context)!
                                .labelReimbursableShort,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.tertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (item.expense.receiptPath != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Tooltip(
                      message: AppLocalizations.of(context)!.msgReceiptAttached,
                      child: Icon(
                        Icons.attachment,
                        size: 14,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '${item.expense.amount.toStringAsFixed(2)} ${AppLocalizations.of(context)!.currency}',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            SizedBox(
              width: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      size: AppSpacing.iconSm,
                      color: colorScheme.primary,
                      semanticLabel: AppLocalizations.of(context)!.labelEdit,
                    ),
                    onPressed: onEdit,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: AppLocalizations.of(context)!.tooltipEditExpense,
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      size: AppSpacing.iconSm,
                      color: colorScheme.error,
                      semanticLabel: AppLocalizations.of(context)!.labelDelete,
                    ),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: AppLocalizations.of(context)!.tooltipDeleteExpense,
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
