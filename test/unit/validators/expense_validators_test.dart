import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracking_desktop_app/core/validators/expense_validators.dart';

void main() {
  group('ExpenseValidators', () {
    group('validateAmount', () {
      test('should return null for valid amounts', () {
        expect(ExpenseValidators.validateAmount('10'), isNull);
        expect(ExpenseValidators.validateAmount('100.50'), isNull);
        expect(ExpenseValidators.validateAmount('0.01'), isNull);
        expect(ExpenseValidators.validateAmount('999999'), isNull);
      });

      test('should return error for null or empty', () {
        expect(ExpenseValidators.validateAmount(null), isNotNull);
        expect(ExpenseValidators.validateAmount(''), isNotNull);
        expect(ExpenseValidators.validateAmount('   '), isNotNull);
      });

      test('should return error for invalid number format', () {
        expect(ExpenseValidators.validateAmount('abc'), isNotNull);
        expect(ExpenseValidators.validateAmount('12.34.56'), isNotNull);
        expect(ExpenseValidators.validateAmount('12,34'), isNotNull);
      });

      test('should return error for zero or negative amounts', () {
        expect(ExpenseValidators.validateAmount('0'), isNotNull);
        expect(ExpenseValidators.validateAmount('-10'), isNotNull);
        expect(ExpenseValidators.validateAmount('-0.01'), isNotNull);
      });

      test('should return error for amounts exceeding maximum', () {
        expect(ExpenseValidators.validateAmount('1000001'), isNotNull);
        expect(ExpenseValidators.validateAmount('9999999'), isNotNull);
      });

      test('should return error for more than 2 decimal places', () {
        expect(ExpenseValidators.validateAmount('10.123'), isNotNull);
        expect(ExpenseValidators.validateAmount('5.9999'), isNotNull);
      });

      test('should accept exactly 2 decimal places', () {
        expect(ExpenseValidators.validateAmount('10.12'), isNull);
        expect(ExpenseValidators.validateAmount('99.99'), isNull);
      });

      test('should accept 1 decimal place', () {
        expect(ExpenseValidators.validateAmount('10.5'), isNull);
      });
    });

    group('validateDescription', () {
      test('should return null for valid descriptions', () {
        expect(ExpenseValidators.validateDescription('Groceries'), isNull);
        expect(ExpenseValidators.validateDescription('Dinner at restaurant'),
            isNull);
        expect(
            ExpenseValidators.validateDescription(
                'A valid description with 50 chars'),
            isNull);
      });

      test('should return error for null or empty', () {
        expect(ExpenseValidators.validateDescription(null), isNotNull);
        expect(ExpenseValidators.validateDescription(''), isNotNull);
        expect(ExpenseValidators.validateDescription('   '), isNotNull);
      });

      test('should return error for descriptions less than 3 characters', () {
        expect(ExpenseValidators.validateDescription('ab'), isNotNull);
        expect(ExpenseValidators.validateDescription('a'), isNotNull);
      });

      test('should return error for descriptions exceeding maximum length', () {
        final longDesc = 'a' * 201;
        expect(ExpenseValidators.validateDescription(longDesc), isNotNull);
      });

      test('should return error for invalid characters', () {
        expect(
            ExpenseValidators.validateDescription('Test<script>'), isNotNull);
        expect(ExpenseValidators.validateDescription('Test>alert'), isNotNull);
      });

      test('should accept descriptions with special characters', () {
        expect(
            ExpenseValidators.validateDescription('Coffee & Donuts'), isNull);
        expect(ExpenseValidators.validateDescription('Bill for John\'s party'),
            isNull);
        expect(ExpenseValidators.validateDescription('Payment - electricity'),
            isNull);
      });
    });

    group('validateCategory', () {
      test('should return null for valid category IDs', () {
        expect(ExpenseValidators.validateCategory(1), isNull);
        expect(ExpenseValidators.validateCategory(100), isNull);
        expect(ExpenseValidators.validateCategory(9999), isNull);
      });

      test('should return error for null category', () {
        expect(ExpenseValidators.validateCategory(null), isNotNull);
      });

      test('should return error for zero or negative category IDs', () {
        expect(ExpenseValidators.validateCategory(0), isNotNull);
        expect(ExpenseValidators.validateCategory(-1), isNotNull);
      });
    });

    group('validateDate', () {
      test('should return null for valid dates', () {
        final today = DateTime.now();
        final yesterday = today.subtract(const Duration(days: 1));
        final lastWeek = today.subtract(const Duration(days: 7));

        expect(ExpenseValidators.validateDate(today), isNull);
        expect(ExpenseValidators.validateDate(yesterday), isNull);
        expect(ExpenseValidators.validateDate(lastWeek), isNull);
      });

      test('should return error for null date', () {
        expect(ExpenseValidators.validateDate(null), isNotNull);
      });

      test('should return error for future dates', () {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final nextWeek = DateTime.now().add(const Duration(days: 7));

        expect(ExpenseValidators.validateDate(tomorrow), isNotNull);
        expect(ExpenseValidators.validateDate(nextWeek), isNotNull);
      });

      test('should return error for dates more than 10 years old', () {
        final elevenYearsAgo =
            DateTime.now().subtract(const Duration(days: 365 * 11));
        expect(ExpenseValidators.validateDate(elevenYearsAgo), isNotNull);
      });

      test('should accept dates up to 10 years old', () {
        final nineYearsAgo =
            DateTime.now().subtract(const Duration(days: 365 * 9));
        expect(ExpenseValidators.validateDate(nineYearsAgo), isNull);
      });
    });

    group('isValidAmountValue', () {
      test('should return true for valid amounts', () {
        expect(ExpenseValidators.isValidAmountValue(10.0), isTrue);
        expect(ExpenseValidators.isValidAmountValue(0.01), isTrue);
        expect(ExpenseValidators.isValidAmountValue(999999.99), isTrue);
      });

      test('should return false for zero or negative amounts', () {
        expect(ExpenseValidators.isValidAmountValue(0), isFalse);
        expect(ExpenseValidators.isValidAmountValue(-10), isFalse);
      });

      test('should return false for amounts exceeding maximum', () {
        expect(ExpenseValidators.isValidAmountValue(1000001), isFalse);
      });
    });
  });
}
