import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';
import 'package:expense_tracking_desktop_app/features/settings/providers/backup_restore_provider.dart';
import 'package:expense_tracking_desktop_app/providers/app_providers.dart';
import 'package:expense_tracking_desktop_app/services/i_backup_service.dart';

/// ViewModel for backup and restore operations
class BackupRestoreViewModel {
  final Ref _ref;

  BackupRestoreViewModel(this._ref);

  /// Access backup service
  IBackupService get _backupService => _ref.read(backupServiceProvider);

  /// Access state notifier
  BackupRestoreNotifier get _notifier =>
      _ref.read(backupRestoreStateProvider.notifier);

  /// Get current state
  BackupRestoreState get state => _ref.read(backupRestoreStateProvider);

  /// Create a backup to user-selected location
  Future<bool> createBackup() async {
    try {
      // Get default file name
      final defaultFileName = _backupService.getDefaultBackupFileName();

      // Let user choose save location
      final result = await FilePicker.platform.saveFile(
        dialogTitle: AppStrings.labelChooseBackupLocation,
        fileName: defaultFileName,
        type: FileType.custom,
        allowedExtensions: ['sqlite'],
      );

      if (result == null) {
        // User cancelled
        return false;
      }

      _notifier.startBackup();
      _notifier.updateProgress(0.3);

      final success = await _backupService.createBackup(result);

      if (success) {
        _notifier.updateProgress(0.8);

        // Get backup info
        final info = await _backupService.getBackupInfo(result);

        _notifier.completeBackup(result, info: info);
        return true;
      } else {
        _notifier.backupFailed(AppStrings.msgBackupFailed);
        return false;
      }
    } catch (e) {
      final message = e is BackupException
          ? e.message
          : '${AppStrings.msgBackupFailed}: ${e.toString()}';
      _notifier.backupFailed(message);
      return false;
    }
  }

  /// Restore from a user-selected backup file
  Future<bool> restoreFromFile() async {
    try {
      // Let user select backup file
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: AppStrings.labelSelectBackupFile,
        type: FileType.custom,
        allowedExtensions: ['sqlite'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        // User cancelled
        return false;
      }

      final filePath = result.files.first.path;
      if (filePath == null) {
        _notifier.restoreFailed('Invalid file path');
        return false;
      }

      return await restoreBackup(filePath);
    } catch (e) {
      final message = e is RestoreException
          ? e.message
          : '${AppStrings.msgRestoreFailed}: ${e.toString()}';
      _notifier.restoreFailed(message);
      return false;
    }
  }

  /// Restore from a specific backup path
  Future<bool> restoreBackup(String backupPath) async {
    try {
      _notifier.startRestore();
      _notifier.updateProgress(0.2);

      // Validate backup first
      final isValid = await _backupService.validateBackup(backupPath);
      if (!isValid) {
        _notifier.restoreFailed('Invalid backup file');
        return false;
      }

      _notifier.updateProgress(0.5);

      final success = await _backupService.restoreBackup(backupPath);

      if (success) {
        _notifier.updateProgress(1.0);
        _notifier.completeRestore(AppStrings.msgRestoreSuccess);
        return true;
      } else {
        _notifier.restoreFailed(AppStrings.msgRestoreFailed);
        return false;
      }
    } catch (e) {
      final message = e is RestoreException
          ? e.message
          : '${AppStrings.msgRestoreFailed}: ${e.toString()}';
      _notifier.restoreFailed(message);
      return false;
    }
  }

  /// Get info about a backup file
  Future<BackupInfo?> getBackupInfo(String backupPath) async {
    return await _backupService.getBackupInfo(backupPath);
  }

  /// Validate a backup file
  Future<bool> validateBackup(String backupPath) async {
    return await _backupService.validateBackup(backupPath);
  }

  /// Clear any error messages
  void clearError() {
    _notifier.clearError();
  }

  /// Clear any success messages
  void clearSuccess() {
    _notifier.clearSuccess();
  }

  /// Reset state
  void reset() {
    _notifier.reset();
  }
}

/// Provider for BackupRestoreViewModel
final backupRestoreViewModelProvider = Provider<BackupRestoreViewModel>((ref) {
  return BackupRestoreViewModel(ref);
});
