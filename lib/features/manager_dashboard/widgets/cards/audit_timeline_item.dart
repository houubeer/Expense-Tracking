import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/models/audit_log_model.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';

/// Audit timeline item widget for displaying audit log entries
/// Shows avatar, action, manager name, timestamp, and connector line
class AuditTimelineItem extends StatelessWidget {

  const AuditTimelineItem({
    required this.auditLog, super.key,
    this.isLast = false,
  });
  final AuditLog auditLog;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: _getActionColor(colorScheme),
                child: Icon(
                  _getActionIcon(),
                  size: 16,
                  color: Colors.white,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    color: colorScheme.outlineVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.lg),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    auditLog.details,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'by ${auditLog.managerName}',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    auditLog.timeAgo,
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getActionColor(ColorScheme colorScheme) {
    switch (auditLog.action) {
      case AuditAction.approved:
        return Colors.green;
      case AuditAction.rejected:
        return Colors.red;
      case AuditAction.budgetUpdated:
        return colorScheme.primary;
      case AuditAction.employeeAdded:
        return colorScheme.tertiary;
    }
  }

  IconData _getActionIcon() {
    switch (auditLog.action) {
      case AuditAction.approved:
        return Icons.check;
      case AuditAction.rejected:
        return Icons.close;
      case AuditAction.budgetUpdated:
        return Icons.edit;
      case AuditAction.employeeAdded:
        return Icons.person_add;
    }
  }
}
