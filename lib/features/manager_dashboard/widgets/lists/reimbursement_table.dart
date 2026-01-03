import 'package:expense_tracking_desktop_app/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/l10n/app_localizations.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';

import 'package:expense_tracking_desktop_app/features/manager_dashboard/models/expense_model.dart';

/// Reimbursement data model
class Reimbursement {
  const Reimbursement({
    required this.employeeName,
    required this.amount,
    required this.isPaid,
    this.paymentDate,
  });
  final String employeeName;
  final double amount;
  final bool isPaid;
  final DateTime? paymentDate;
}

/// Reimbursement table widget for tracking payments
/// Displays approved expenses awaiting payment
class ReimbursementTable extends StatelessWidget {
  final List<ManagerExpense> expenses;

  const ReimbursementTable({
    super.key,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Convert ManagerExpense to local Reimbursement model
    final reimbursements = expenses.map((e) => Reimbursement(
      employeeName: e.employeeName,
      amount: e.amount,
      isPaid: e.reimbursedAt != null,
      paymentDate: e.reimbursedAt,
    )).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with export buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.reimbursements,
              style: AppTextStyles.heading3,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // ================= TABLE =================
        LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: constraints.maxWidth,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                          colorScheme.surfaceContainerHighest,
                        ),
                        columnSpacing: AppSpacing.xl,
                        columns: [
                          _ReimbursementHeader('Employee'),
                          _ReimbursementHeader('Approved Amount'),
                          _ReimbursementHeader(AppStrings.labelStatus),
                          _ReimbursementHeader('Payment Date'),
                        ],
                        rows: reimbursements.map((reimbursement) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  reimbursement.employeeName,
                                  style: AppTextStyles.bodyMedium,
                                ),
                              ),
                              DataCell(
                                Text(
                                  '${reimbursement.amount.toStringAsFixed(2)} ${AppStrings.currency}',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.sm,
                                  ),
                                  decoration: BoxDecoration(
                                    color: reimbursement.isPaid
                                        ? Colors.green.withValues(alpha: 0.2)
                                        : Colors.orange.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusSm,
                                    ),
                                  ),
                                  child: Text(
                                    reimbursement.isPaid ? 'Paid' : 'Unpaid',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: reimbursement.isPaid
                                          ? Colors.green.shade700
                                          : Colors.orange.shade700,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  reimbursement.paymentDate != null
                                      ? '${reimbursement.paymentDate!.day}/${reimbursement.paymentDate!.month}/${reimbursement.paymentDate!.year}'
                                      : '-',
                                  style: AppTextStyles.bodySmall,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Table header helper (clean + consistent)

class _ReimbursementHeader extends DataColumn {
  _ReimbursementHeader(String text)
      : super(
          label: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        );
}
