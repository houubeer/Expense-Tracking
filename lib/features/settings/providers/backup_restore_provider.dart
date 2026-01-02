import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracking_desktop_app/services/i_backup_service.dart';

/// State for backup/restore operations
class BackupRestoreState {

  const BackupRestoreState({
    this.isBackingUp = false,
    this.isRestoring = false,
    this.lastBackupPath,
    this.error,
    this.successMessage,
    this.lastBackupInfo,
    this.progress,
  });

  /// Initial state
  factory BackupRestoreState.initial() {
    return const BackupRestoreState();
  }
  final bool isBackingUp;
  final bool isRestoring;
  final String? lastBackupPath;
  final String? error;
  final String? successMessage;
  final BackupInfo? lastBackupInfo;
  final double? progress;

  /// Check if any operation is in progress
  bool get isLoading => isBackingUp || isRestoring;

  /// Copy with method for immutable state updates
  BackupRestoreState copyWith({
    bool? isBackingUp,
    bool? isRestoring,
    String? lastBackupPath,
    String? error,
    String? successMessage,
    BackupInfo? lastBackupInfo,
    double? progress,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearLastBackupPath = false,
  }) {
    return BackupRestoreState(
      isBackingUp: isBackingUp ?? this.isBackingUp,
      isRestoring: isRestoring ?? this.isRestoring,
      lastBackupPath:
          clearLastBackupPath ? null : (lastBackupPath ?? this.lastBackupPath),
      error: clearError ? null : (error ?? this.error),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
      lastBackupInfo: lastBackupInfo ?? this.lastBackupInfo,
      progress: progress ?? this.progress,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BackupRestoreState &&
        other.isBackingUp == isBackingUp &&
        other.isRestoring == isRestoring &&
        other.lastBackupPath == lastBackupPath &&
        other.error == error &&
        other.successMessage == successMessage &&
        other.lastBackupInfo == lastBackupInfo &&
        other.progress == progress;
  }

  @override
  int get hashCode {
    return Object.hash(
      isBackingUp,
      isRestoring,
      lastBackupPath,
      error,
      successMessage,
      lastBackupInfo,
      progress,
    );
  }
}

/// Provider for backup/restore state
final backupRestoreStateProvider =
    StateNotifierProvider<BackupRestoreNotifier, BackupRestoreState>((ref) {
  return BackupRestoreNotifier();
});

/// State notifier for backup/restore operations
class BackupRestoreNotifier extends StateNotifier<BackupRestoreState> {
  BackupRestoreNotifier() : super(BackupRestoreState.initial());

  /// Start backup operation
  void startBackup() {
    state = state.copyWith(
      isBackingUp: true,
      clearError: true,
      clearSuccess: true,
      progress: 0,
    );
  }

  /// Complete backup operation successfully
  void completeBackup(String backupPath, {BackupInfo? info}) {
    state = state.copyWith(
      isBackingUp: false,
      lastBackupPath: backupPath,
      lastBackupInfo: info,
      progress: 1.0,
    );
  }

  /// Backup operation failed
  void backupFailed(String errorMessage) {
    state = state.copyWith(
      isBackingUp: false,
      error: errorMessage,
    );
  }

  /// Start restore operation
  void startRestore() {
    state = state.copyWith(
      isRestoring: true,
      clearError: true,
      clearSuccess: true,
      progress: 0,
    );
  }

  /// Complete restore operation successfully
  void completeRestore(String successMessage) {
    state = state.copyWith(
      isRestoring: false,
      successMessage: successMessage,
      progress: 1.0,
    );
  }

  /// Restore operation failed
  void restoreFailed(String errorMessage) {
    state = state.copyWith(
      isRestoring: false,
      error: errorMessage,
    );
  }

  /// Update progress
  void updateProgress(double progress) {
    state = state.copyWith(progress: progress);
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Clear success message
  void clearSuccess() {
    state = state.copyWith(clearSuccess: true);
  }

  /// Reset state to initial
  void reset() {
    state = BackupRestoreState.initial();
  }
}
