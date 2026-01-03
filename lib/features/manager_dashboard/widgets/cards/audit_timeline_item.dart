import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/models/audit_log_model.dart';
import 'package:expense_tracking_desktop_app/l10n/app_localizations.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';

/// Audit timeline item widget for displaying audit log entries
/// Shows avatar, action, manager name, timestamp, and connector line
class AuditTimelineItem extends StatelessWidget {
  const AuditTimelineItem({
    required this.auditLog,
    super.key,
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
                    '${AppLocalizations.of(context)!.labelBy} ${auditLog.managerName}',
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
    final actionLower = auditLog.action.toLowerCase();
    if (actionLower.contains('approve')) return Colors.green;
    if (actionLower.contains('reject')) return Colors.red;
    if (actionLower.contains('budget')) return colorScheme.primary;
    if (actionLower.contains('employee')) return colorScheme.tertiary;
    return colorScheme.outlineVariant;
  }

  IconData _getActionIcon() {
    final actionLower = auditLog.action.toLowerCase();
    if (actionLower.contains('approve')) return Icons.check;
    if (actionLower.contains('reject')) return Icons.close;
    if (actionLower.contains('budget')) return Icons.edit;
    if (actionLower.contains('employee') && actionLower.contains('add')) {
      return Icons.person_add;
    }
    if (actionLower.contains('suspend')) return Icons.person_off;
    if (actionLower.contains('activate')) return Icons.person;
    if (actionLower.contains('remove')) return Icons.person_remove;
    if (actionLower.contains('comment')) return Icons.comment;
    return Icons.info;
  }
}
