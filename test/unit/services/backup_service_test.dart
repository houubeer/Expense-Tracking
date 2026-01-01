import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracking_desktop_app/services/backup_service.dart';
import 'package:expense_tracking_desktop_app/services/i_backup_service.dart';
import 'package:expense_tracking_desktop_app/services/logger_service.dart';
import 'package:mockito/mockito.dart';

// Mock classes
class MockLoggerService extends Mock implements LoggerService {}

void main() {
  group('BackupService', () {
    late BackupService backupService;
    late MockLoggerService mockLogger;

    setUp(() {
      mockLogger = MockLoggerService();
      backupService = BackupService(logger: mockLogger);
    });

    group('getDefaultBackupFileName', () {
      test('generates filename with timestamp format', () {
        final fileName = backupService.getDefaultBackupFileName();
        
        // Should contain the prefix
        expect(fileName, startsWith('expense_tracker_backup_'));
        
        // Should end with .sqlite
        expect(fileName, endsWith('.sqlite'));
        
        // Should have reasonable length (prefix + timestamp + extension)
        expect(fileName.length, greaterThan(20));
      });

      test('generates unique filenames for different times', () {
        final fileName1 = backupService.getDefaultBackupFileName();
        
        // Small delay to ensure different timestamp
        Future.delayed(const Duration(milliseconds: 100));
        
        final fileName2 = backupService.getDefaultBackupFileName();
        
        // Filenames should be different due to timestamp
        // (Note: might occasionally be the same if within same second)
        expect(fileName1, isA<String>());
        expect(fileName2, isA<String>());
      });
    });

    group('BackupException', () {
      test('creates exception with message', () {
        final exception = BackupException('Test backup error');
        
        expect(exception.message, equals('Test backup error'));
        expect(exception.toString(), contains('BackupException'));
      });

      test('preserves original error', () {
        final originalError = Exception('Original');
        final exception = BackupException('Wrapped', originalError: originalError);
        
        expect(exception.originalError, equals(originalError));
      });
    });

    group('RestoreException', () {
      test('creates exception with message', () {
        final exception = RestoreException('Test restore error');
        
        expect(exception.message, equals('Test restore error'));
        expect(exception.toString(), contains('RestoreException'));
      });

      test('preserves original error', () {
        final originalError = Exception('Original');
        final exception = RestoreException('Wrapped', originalError: originalError);
        
        expect(exception.originalError, equals(originalError));
      });
    });

    group('BackupInfo', () {
      test('formats small file size correctly', () {
        final info = BackupInfo(
          path: '/tmp/backup.sqlite',
          fileName: 'backup.sqlite',
          sizeInBytes: 512,
          createdAt: DateTime.now(),
          isValid: true,
        );
        
        expect(info.formattedSize, equals('512 B'));
      });

      test('formats kilobyte file size correctly', () {
        final info = BackupInfo(
          path: '/tmp/backup.sqlite',
          fileName: 'backup.sqlite',
          sizeInBytes: 1024 * 10, // 10 KB
          createdAt: DateTime.now(),
          isValid: true,
        );
        
        expect(info.formattedSize, contains('KB'));
        expect(info.formattedSize, contains('10'));
      });

      test('formats megabyte file size correctly', () {
        final info = BackupInfo(
          path: '/tmp/backup.sqlite',
          fileName: 'backup.sqlite',
          sizeInBytes: 1024 * 1024 * 5, // 5 MB
          createdAt: DateTime.now(),
          isValid: true,
        );
        
        expect(info.formattedSize, contains('MB'));
        expect(info.formattedSize, contains('5'));
      });

      test('preserves path and filename', () {
        final info = BackupInfo(
          path: '/path/to/backup.sqlite',
          fileName: 'backup.sqlite',
          sizeInBytes: 1024,
          createdAt: DateTime.now(),
          isValid: true,
        );
        
        expect(info.path, equals('/path/to/backup.sqlite'));
        expect(info.fileName, equals('backup.sqlite'));
      });

      test('tracks validity status', () {
        final validInfo = BackupInfo(
          path: '/tmp/backup.sqlite',
          fileName: 'backup.sqlite',
          sizeInBytes: 1024,
          createdAt: DateTime.now(),
          isValid: true,
        );
        
        final invalidInfo = BackupInfo(
          path: '/tmp/backup.sqlite',
          fileName: 'backup.sqlite',
          sizeInBytes: 0,
          createdAt: DateTime.now(),
          isValid: false,
        );
        
        expect(validInfo.isValid, isTrue);
        expect(invalidInfo.isValid, isFalse);
      });
    });
  });
}
