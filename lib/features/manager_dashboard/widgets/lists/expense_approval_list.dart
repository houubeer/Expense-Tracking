import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/models/expense_model.dart';
import 'package:expense_tracking_desktop_app/l10n/app_localizations.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/app_config.dart';
import 'package:expense_tracking_desktop_app/widgets/animations/staggered_list_animation.dart';

class ExpenseApprovalList extends StatelessWidget {
  const ExpenseApprovalList({
    required this.expenses,
    super.key,
    this.onApprove,
    this.onReject,
    this.onComment,
    this.onViewDetails,
  });
  final List<ManagerExpense> expenses;
  final void Function(String expenseId)? onApprove;
  final void Function(String expenseId)? onReject;
  final void Function(String expenseId)? onComment;
  final void Function(ManagerExpense expense)? onViewDetails;

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        return FadeInListItem(
          index: index,
          child: _ExpenseApprovalItem(
            expense: expenses[index],
            onApprove: onApprove,
            onReject: onReject,
            onComment: onComment,
            onViewDetails: onViewDetails,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              AppLocalizations.of(context)!.titleNoPendingApprovals,
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              AppLocalizations.of(context)!.msgAllExpensesProcessed,
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseApprovalItem extends StatelessWidget {
  const _ExpenseApprovalItem({
    required this.expense,
    this.onApprove,
    this.onReject,
    this.onComment,
    this.onViewDetails,
  });
  final ManagerExpense expense;
  final void Function(String)? onApprove;
  final void Function(String)? onReject;
  final void Function(String)? onComment;
  final void Function(ManagerExpense)? onViewDetails;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
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
            offset:
                const Offset(AppConfig.shadowOffsetX, AppConfig.shadowOffsetY),
          ),
        ],
      ),
      child: Row(
        children: [
          // Employee avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
            child: Text(
              _getInitials(expense.employeeName),
              style: AppTextStyles.bodySmall.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          // Employee name
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.employeeName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (expense.description != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    expense.description!,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          // Amount
          Expanded(
            child: Text(
              '${expense.amount.toStringAsFixed(2)} ${AppLocalizations.of(context)!.currency}',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          // Category
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Text(
                expense.category,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          // Date
          Expanded(
            child: Text(
              '${expense.date.day}/${expense.date.month}/${expense.date.year}',
              style: AppTextStyles.bodySmall,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: colorScheme.secondary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Text(
              expense.status.displayName,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.secondary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => onViewDetails?.call(expense),
                icon: const Icon(Icons.visibility_outlined),
                color: colorScheme.primary,
                tooltip: AppLocalizations.of(context)!.tooltipViewDetails,
              ),
              IconButton(
                onPressed: () => onApprove?.call(expense.id),
                icon: const Icon(Icons.check_circle_outline),
                color: Colors.green,
                tooltip: AppLocalizations.of(context)!.tooltipApprove,
              ),
              IconButton(
                onPressed: () => _showRejectDialog(context, expense.id),
                icon: const Icon(Icons.cancel_outlined),
                color: Colors.red,
                tooltip: AppLocalizations.of(context)!.tooltipReject,
              ),
              IconButton(
                onPressed: () => onComment?.call(expense.id),
                icon: const Icon(Icons.comment_outlined),
                color: colorScheme.primary,
                tooltip: AppLocalizations.of(context)!.tooltipComment,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  void _showRejectDialog(BuildContext context, String expenseId) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.titleRejectExpense),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.labelRejectionReason,
            hintText: AppLocalizations.of(context)!.hintRejectionReason,
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.btnCancel),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                onReject?.call(expenseId);
                Navigator.of(context).pop();
              }
            },
            child: Text(AppLocalizations.of(context)!.btnReject),
          ),
        ],
      ),
    );
  }
}
