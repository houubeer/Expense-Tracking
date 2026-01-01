import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/features/settings/providers/backup_restore_provider.dart';
import 'package:expense_tracking_desktop_app/features/settings/view_models/backup_restore_view_model.dart';
import 'package:expense_tracking_desktop_app/features/settings/widgets/backup_card.dart';
import 'package:expense_tracking_desktop_app/features/settings/widgets/restore_card.dart';
import 'package:expense_tracking_desktop_app/features/settings/widgets/restore_confirmation_dialog.dart';
import 'package:expense_tracking_desktop_app/services/i_backup_service.dart';

class BackupRestoreContent extends ConsumerWidget {
  const BackupRestoreContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(backupRestoreStateProvider);
    final viewModel = ref.watch(backupRestoreViewModelProvider);

    // Listen for error/success messages
    ref.listen<BackupRestoreState>(backupRestoreStateProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        _showErrorSnackBar(context, next.error!);
        viewModel.clearError();
      }
      if (next.successMessage != null &&
          next.successMessage != prev?.successMessage) {
        _showSuccessSnackBar(context, next.successMessage!);
        viewModel.clearSuccess();
      }
      if (next.lastBackupPath != null &&
          next.lastBackupPath != prev?.lastBackupPath &&
          prev?.isBackingUp == true) {
        _showSuccessSnackBar(context, 'Backup saved to: ${_getFileName(next.lastBackupPath!)}');
      }
    });

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Data Management',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Backup and restore your data',
            style: AppTextStyles.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildBackupRestoreSection(context, state, viewModel),
        ],
      ),
    );
  }

  Widget _buildBackupRestoreSection(
    BuildContext context,
    BackupRestoreState state,
    BackupRestoreViewModel viewModel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Backup and Restore cards in a responsive layout
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 800) {
              // Wide layout - side by side
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: BackupCard(
                      onBackupPressed: () => _handleBackup(viewModel),
                      isLoading: state.isBackingUp,
                      progress: state.isBackingUp ? state.progress : null,
                      lastBackupPath: state.lastBackupPath,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: RestoreCard(
                      onRestorePressed: () => _handleRestore(context, viewModel),
                      isLoading: state.isRestoring,
                      progress: state.isRestoring ? state.progress : null,
                    ),
                  ),
                ],
              );
            } else {
              // Narrow layout - stacked
              return Column(
                children: [
                  BackupCard(
                    onBackupPressed: () => _handleBackup(viewModel),
                    isLoading: state.isBackingUp,
                    progress: state.isBackingUp ? state.progress : null,
                    lastBackupPath: state.lastBackupPath,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  RestoreCard(
                    onRestorePressed: () => _handleRestore(context, viewModel),
                    isLoading: state.isRestoring,
                    progress: state.isRestoring ? state.progress : null,
                  ),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Future<void> _handleBackup(BackupRestoreViewModel viewModel) async {
    await viewModel.createBackup();
  }

  Future<void> _handleRestore(BuildContext context, BackupRestoreViewModel viewModel) async {
    // Let user select backup file first
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: AppStrings.labelSelectBackupFile,
      type: FileType.custom,
      allowedExtensions: ['sqlite'],
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) {
      return; // User cancelled
    }

    final filePath = result.files.first.path;
    if (filePath == null) {
      _showErrorSnackBar(context, 'Invalid file path');
      return;
    }

    // Get backup info for display in confirmation dialog
    final backupInfo = await viewModel.getBackupInfo(filePath);

    // Show confirmation dialog with backup details
    if (context.mounted) {
      final confirmed = await _showRestoreConfirmationDialog(context, backupInfo);
      if (confirmed == true) {
        await viewModel.restoreBackup(filePath);
      }
    }
  }

  Future<bool?> _showRestoreConfirmationDialog(BuildContext context, BackupInfo? backupInfo) {
    return showDialog<bool>(
      context: context,
      builder: (context) => RestoreConfirmationDialog(
        backupInfo: backupInfo,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _getFileName(String path) {
    return path.split(RegExp(r'[/\\]')).last;
  }
}
