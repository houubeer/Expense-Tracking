import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:expense_tracking_desktop_app/services/i_backup_service.dart';
import 'package:expense_tracking_desktop_app/services/logger_service.dart';
// ignore: depend_on_referenced_packages
import 'package:sqlite3/sqlite3.dart';

/// Implementation of [IBackupService] for SQLite database backup and restore.
///
/// This service handles:
/// - Creating backup copies of the database file
/// - Restoring database from backup files
/// - Validating backup file integrity
class BackupService implements IBackupService {
  final LoggerService _logger;
  static const String _dbFileName = 'expense_tracker.sqlite';

  BackupService({LoggerService? logger})
      : _logger = logger ?? LoggerService.instance;

  /// Gets the path to the current database file.
  Future<String> _getDatabasePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return p.join(dir.path, _dbFileName);
  }

  @override
  Future<bool> createBackup(String destinationPath) async {
    try {
      _logger.info('BackupService: Creating backup to $destinationPath');

      final dbPath = await _getDatabasePath();
      final dbFile = File(dbPath);

      if (!await dbFile.exists()) {
        throw BackupException('Database file not found at $dbPath');
      }

      // Ensure destination directory exists
      final destDir = Directory(p.dirname(destinationPath));
      if (!await destDir.exists()) {
        await destDir.create(recursive: true);
      }

      // Copy the database file
      await dbFile.copy(destinationPath);

      // Validate the backup was successful
      final backupFile = File(destinationPath);
      if (!await backupFile.exists()) {
        throw BackupException('Backup file was not created');
      }

      final isValid = await validateBackup(destinationPath);
      if (!isValid) {
        // Clean up invalid backup
        await backupFile.delete();
        throw BackupException('Backup file validation failed');
      }

      _logger.info('BackupService: Backup created successfully');
      return true;
    } catch (e, stackTrace) {
      _logger.error('BackupService: Failed to create backup',
          error: e, stackTrace: stackTrace);
      if (e is BackupException) rethrow;
      throw BackupException('Failed to create backup: ${e.toString()}',
          originalError: e);
    }
  }

  @override
  Future<bool> restoreBackup(String sourcePath) async {
    try {
      _logger.info('BackupService: Restoring backup from $sourcePath');

      final backupFile = File(sourcePath);
      if (!await backupFile.exists()) {
        throw RestoreException('Backup file not found at $sourcePath');
      }

      // Validate backup before restoring
      final isValid = await validateBackup(sourcePath);
      if (!isValid) {
        throw RestoreException('Invalid backup file');
      }

      final dbPath = await _getDatabasePath();
      final dbFile = File(dbPath);

      // Create a safety backup of current database
      if (await dbFile.exists()) {
        final safetyBackupPath =
            '$dbPath.safety.${DateTime.now().millisecondsSinceEpoch}';
        await dbFile.copy(safetyBackupPath);
        _logger.info(
            'BackupService: Created safety backup at $safetyBackupPath');
      }

      // Replace the database file with the backup
      await backupFile.copy(dbPath);

      _logger.info('BackupService: Backup restored successfully');
      return true;
    } catch (e, stackTrace) {
      _logger.error('BackupService: Failed to restore backup',
          error: e, stackTrace: stackTrace);
      if (e is RestoreException) rethrow;
      throw RestoreException('Failed to restore backup: ${e.toString()}',
          originalError: e);
    }
  }

  @override
  Future<bool> validateBackup(String backupPath) async {
    try {
      final file = File(backupPath);
      if (!await file.exists()) {
        return false;
      }

      // Check file size
      final stat = await file.stat();
      if (stat.size == 0) {
        return false;
      }

      // Try to open and validate the database
      final db = sqlite3.open(backupPath);
      try {
        // Run integrity check
        final result = db.select('PRAGMA integrity_check');
        if (result.isEmpty || result.first['integrity_check'] != 'ok') {
          return false;
        }

        // Check for required tables
        final tables = db.select(
          "SELECT name FROM sqlite_master WHERE type='table' AND name IN ('expenses', 'categories')",
        );
        if (tables.length < 2) {
          _logger.warning(
              'BackupService: Backup missing required tables');
          return false;
        }

        return true;
      } finally {
        db.dispose();
      }
    } catch (e) {
      _logger.warning('BackupService: Backup validation failed: $e');
      return false;
    }
  }

  @override
  String getDefaultBackupFileName() {
    final now = DateTime.now();
    final timestamp =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
    return 'expense_tracker_backup_$timestamp.sqlite';
  }

  @override
  Future<BackupInfo?> getBackupInfo(String backupPath) async {
    try {
      final file = File(backupPath);
      if (!await file.exists()) {
        return null;
      }

      final stat = await file.stat();
      final isValid = await validateBackup(backupPath);

      return BackupInfo(
        path: backupPath,
        fileName: p.basename(backupPath),
        sizeInBytes: stat.size,
        createdAt: stat.modified,
        isValid: isValid,
      );
    } catch (e) {
      _logger.error('BackupService: Failed to get backup info', error: e);
      return null;
    }
  }
}
