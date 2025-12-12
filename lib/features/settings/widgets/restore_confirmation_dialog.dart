import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/services/i_backup_service.dart';

/// Dialog widget for confirming restore operation with backup details
class RestoreConfirmationDialog extends StatelessWidget {
  final BackupInfo? backupInfo;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const RestoreConfirmationDialog({
    super.key,
    this.backupInfo,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Spacing.radiusMd),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(Spacing.sm),
            decoration: BoxDecoration(
              color: AppColors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Spacing.radiusSm),
            ),
            child: const Icon(
              Icons.restore_outlined,
              color: AppColors.orange,
              size: 24,
            ),
          ),
          const SizedBox(width: Spacing.md),
          const Text('Confirm Restore'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Backup info card
          if (backupInfo != null) ...[
            _buildBackupInfoCard(),
            const SizedBox(height: Spacing.lg),
          ],

          // Warning section
          Container(
            padding: const EdgeInsets.all(Spacing.md),
            decoration: BoxDecoration(
              color: AppColors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Spacing.radiusSm),
              border: Border.all(
                color: AppColors.red.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_outlined,
                      color: AppColors.red,
                      size: 20,
                    ),
                    const SizedBox(width: Spacing.sm),
                    Text(
                      'Warning',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.sm),
                Text(
                  'This action will replace ALL current data with the backup data. '
                  'Any expenses, categories, or budgets created after this backup '
                  'will be permanently lost.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.md),

          Text(
            'Are you sure you want to continue?',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.orange,
            foregroundColor: Colors.white,
          ),
          child: const Text('Restore Data'),
        ),
      ],
    );
  }

  Widget _buildBackupInfoCard() {
    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(Spacing.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Backup Details',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          _buildInfoRow(Icons.insert_drive_file_outlined, 'File',
              backupInfo!.fileName),
          const SizedBox(height: Spacing.xs),
          _buildInfoRow(Icons.storage_outlined, 'Size',
              backupInfo!.formattedSize),
          const SizedBox(height: Spacing.xs),
          _buildInfoRow(Icons.calendar_today_outlined, 'Created',
              _formatDate(backupInfo!.createdAt)),
          const SizedBox(height: Spacing.xs),
          _buildInfoRow(
            backupInfo!.isValid
                ? Icons.check_circle_outline
                : Icons.error_outline,
            'Status',
            backupInfo!.isValid ? 'Valid' : 'Invalid',
            valueColor: backupInfo!.isValid ? AppColors.green : AppColors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: Spacing.sm),
        Text(
          '$label: ',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w500,
              color: valueColor ?? AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
