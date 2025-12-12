import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';

/// Card widget for backup data functionality
class BackupCard extends StatelessWidget {
  final VoidCallback onBackupPressed;
  final bool isLoading;
  final double? progress;
  final String? lastBackupPath;

  const BackupCard({
    super.key,
    required this.onBackupPressed,
    this.isLoading = false,
    this.progress,
    this.lastBackupPath,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Spacing.radiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(Spacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(Spacing.radiusSm),
                  ),
                  child: const Icon(
                    Icons.backup_outlined,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.titleBackupData,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: Spacing.xxs),
                      Text(
                        AppStrings.descBackup,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.lg),

            // Progress indicator when loading
            if (isLoading && progress != null) ...[
              LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.border,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              const SizedBox(height: Spacing.md),
            ],

            // Last backup info
            if (lastBackupPath != null && !isLoading) ...[
              Container(
                padding: const EdgeInsets.all(Spacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(Spacing.radiusSm),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: AppColors.green,
                      size: 16,
                    ),
                    const SizedBox(width: Spacing.xs),
                    Expanded(
                      child: Text(
                        'Last backup: ${_getFileName(lastBackupPath!)}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.green,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.md),
            ],

            // Backup button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : onBackupPressed,
                icon: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.cloud_upload_outlined),
                label: Text(
                  isLoading ? 'Creating backup...' : AppStrings.btnBackupNow,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Spacing.radiusSm),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFileName(String path) {
    return path.split(RegExp(r'[/\\]')).last;
  }
}
