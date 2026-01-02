import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';

/// Mock reimbursement data model
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

  const ReimbursementTable({
    super.key,
    this.onExportExcel,
    this.onExportPdf,
  });
  final VoidCallback? onExportExcel;
  final VoidCallback? onExportPdf;

  // Mock reimbursement data
  static final List<Reimbursement> _mockReimbursements = [
    const Reimbursement(
      employeeName: 'Sarah Johnson',
      amount: 12500.00,
      isPaid: false,
    ),
    Reimbursement(
      employeeName: 'Emily Rodriguez',
      amount: 850.00,
      isPaid: true,
      paymentDate: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Reimbursement(
      employeeName: 'Jessica Williams',
      amount: 2100.00,
      isPaid: true,
      paymentDate: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Reimbursement(
      employeeName: 'Amanda Brown',
      amount: 650.00,
      isPaid: true,
      paymentDate: DateTime.now().subtract(const Duration(days: 8)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with export buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Reimbursements',
              style: AppTextStyles.heading3,
            ),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: onExportExcel,
                  icon: const Icon(Icons.table_chart, size: AppSpacing.iconXs),
                  label: const Text('Export Excel'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: onExportPdf,
                  icon: const Icon(Icons.picture_as_pdf, size: AppSpacing.iconXs),
                  label: const Text('Export PDF'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        // Table
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(
              colorScheme.surfaceContainerHighest,
            ),
            columns: [
              DataColumn(
                label: Text(
                  'Employee',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Approved Amount',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  AppStrings.labelStatus,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Payment Date',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            rows: _mockReimbursements.map((reimbursement) {
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
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
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
      ],
    );
  }
}
