/// Interface for backup and restore operations.
///
/// Defines the contract for backing up and restoring application data,
/// following the Dependency Inversion Principle (DIP).
abstract class IBackupService {
  /// Creates a backup of the current database to the specified path.
  ///
  /// [destinationPath] The full path where the backup file should be saved.
  ///
  /// Returns `true` if the backup was successful.
  ///
  /// Throws [BackupException] if the backup fails.
  Future<bool> createBackup(String destinationPath);

  /// Restores the database from a backup file.
  ///
  /// [sourcePath] The full path to the backup file.
  ///
  /// Returns `true` if the restore was successful.
  ///
  /// Throws [RestoreException] if the restore fails.
  Future<bool> restoreBackup(String sourcePath);

  /// Validates a backup file to ensure it's a valid database.
  ///
  /// [backupPath] The path to the backup file to validate.
  ///
  /// Returns `true` if the backup file is valid.
  Future<bool> validateBackup(String backupPath);

  /// Gets the default backup file name with timestamp.
  ///
  /// Returns a string in format: expense_tracker_backup_YYYYMMDD_HHMMSS.sqlite
  String getDefaultBackupFileName();

  /// Gets information about a backup file.
  ///
  /// [backupPath] The path to the backup file.
  ///
  /// Returns [BackupInfo] containing metadata about the backup.
  Future<BackupInfo?> getBackupInfo(String backupPath);
}

/// Information about a backup file.
class BackupInfo {
  /// The file path of the backup.
  final String path;

  /// The file name of the backup.
  final String fileName;

  /// The size of the backup file in bytes.
  final int sizeInBytes;

  /// When the backup was created.
  final DateTime createdAt;

  /// Whether the backup is valid.
  final bool isValid;

  const BackupInfo({
    required this.path,
    required this.fileName,
    required this.sizeInBytes,
    required this.createdAt,
    required this.isValid,
  });

  /// Returns a human-readable file size.
  String get formattedSize {
    if (sizeInBytes < 1024) return '$sizeInBytes B';
    if (sizeInBytes < 1024 * 1024) {
      return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Exception thrown when backup operations fail.
class BackupException implements Exception {
  final String message;
  final dynamic originalError;

  BackupException(this.message, {this.originalError});

  @override
  String toString() => 'BackupException: $message';
}

/// Exception thrown when restore operations fail.
class RestoreException implements Exception {
  final String message;
  final dynamic originalError;

  RestoreException(this.message, {this.originalError});

  @override
  String toString() => 'RestoreException: $message';
}
