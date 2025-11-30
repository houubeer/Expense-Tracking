import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracking_desktop_app/core/errors/error_mapper.dart';
import 'package:expense_tracking_desktop_app/core/exceptions.dart';

void main() {
  group('ErrorMapper', () {
    group('getUserFriendlyMessage', () {
      test('should map database UNIQUE constraint errors', () {
        final error =
            DatabaseException('UNIQUE constraint failed: categories.name');
        final message = ErrorMapper.getUserFriendlyMessage(error);

        expect(message, contains('already exists'));
        expect(message, isNot(contains('UNIQUE')));
        expect(message, isNot(contains('constraint')));
      });

      test('should map database locked errors', () {
        final error = DatabaseException('database is locked');
        final message = ErrorMapper.getUserFriendlyMessage(error);

        expect(message, contains('busy'));
        expect(message, isNot(contains('locked')));
      });

      test('should map foreign key constraint errors', () {
        final error = DatabaseException('FOREIGN KEY constraint failed');
        final message = ErrorMapper.getUserFriendlyMessage(error);

        expect(message, contains('being used'));
        expect(message, isNot(contains('FOREIGN KEY')));
      });

      test('should pass through validation errors', () {
        final error = ValidationException('Invalid input');
        final message = ErrorMapper.getUserFriendlyMessage(error);

        expect(message, equals('Invalid input'));
      });

      test('should map generic database errors', () {
        final error = DatabaseException('Unknown database error');
        final message = ErrorMapper.getUserFriendlyMessage(error);

        expect(message, contains('Unable to save'));
      });

      test('should map network exceptions', () {
        final error = NetworkException('Connection failed');
        final message = ErrorMapper.getUserFriendlyMessage(error);

        expect(message, contains('Network'));
      });

      test('should handle generic errors', () {
        final message = ErrorMapper.getUserFriendlyMessage('Unknown error');

        expect(message, isNotEmpty);
        expect(message, isNot(contains('Exception')));
      });
    });

    group('getActionableHelp', () {
      test('should provide help for locked database', () {
        final error = DatabaseException('database is locked');
        final help = ErrorMapper.getActionableHelp(error);

        expect(help, contains('Wait'));
      });

      test('should provide help for corruption', () {
        final error = DatabaseException('database disk image is malformed');
        final help = ErrorMapper.getActionableHelp(error);

        expect(help, contains('restart'));
      });

      test('should provide help for foreign key errors', () {
        final error = DatabaseException('FOREIGN KEY constraint failed');
        final help = ErrorMapper.getActionableHelp(error);

        expect(help, anyOf(contains('Delete'), contains('reassign')));
      });
    });

    group('getErrorCode', () {
      test('should generate database error codes', () {
        final error = DatabaseException('Test error');
        final code = ErrorMapper.getErrorCode(error);

        expect(code, startsWith('DB-'));
      });

      test('should generate validation error codes', () {
        final error = ValidationException('Test error');
        final code = ErrorMapper.getErrorCode(error);

        expect(code, startsWith('VAL-'));
      });

      test('should generate network error codes', () {
        final error = NetworkException('Test error');
        final code = ErrorMapper.getErrorCode(error);

        expect(code, startsWith('NET-'));
      });

      test('should generate generic error codes', () {
        final code = ErrorMapper.getErrorCode('Generic error');

        expect(code, startsWith('ERR-'));
      });

      test('should include timestamp in error code', () {
        final code = ErrorMapper.getErrorCode('Test');
        final parts = code.split('-');

        expect(parts.length, equals(2));
        expect(int.tryParse(parts[1]), isNotNull);
      });
    });

    group('shouldReportError', () {
      test('should not report validation errors', () {
        final error = ValidationException('Invalid input');
        expect(ErrorMapper.shouldReportError(error), isFalse);
      });

      test('should not report duplicate entry errors', () {
        final error = DatabaseException('UNIQUE constraint failed');
        expect(ErrorMapper.shouldReportError(error), isFalse);
      });

      test('should report database errors', () {
        final error = DatabaseException('Disk I/O error');
        expect(ErrorMapper.shouldReportError(error), isTrue);
      });

      test('should report network errors', () {
        final error = NetworkException('Connection failed');
        expect(ErrorMapper.shouldReportError(error), isTrue);
      });

      test('should report generic errors', () {
        expect(ErrorMapper.shouldReportError('Unknown error'), isTrue);
      });
    });
  });
}
