import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracking_desktop_app/core/validators/category_validators.dart';

void main() {
  group('CategoryValidators', () {
    group('validateCategoryName', () {
      test('should return null for valid category names', () {
        expect(CategoryValidators.validateCategoryName('Food'), isNull);
        expect(CategoryValidators.validateCategoryName('Transport'), isNull);
        expect(CategoryValidators.validateCategoryName('Entertainment & Fun'),
            isNull);
      });

      test('should return error for null or empty', () {
        expect(CategoryValidators.validateCategoryName(null), isNotNull);
        expect(CategoryValidators.validateCategoryName(''), isNotNull);
        expect(CategoryValidators.validateCategoryName('   '), isNotNull);
      });

      test('should return error for names less than 2 characters', () {
        expect(CategoryValidators.validateCategoryName('a'), isNotNull);
      });

      test('should return error for names exceeding maximum length', () {
        final longName = 'a' * 51;
        expect(CategoryValidators.validateCategoryName(longName), isNotNull);
      });

      test('should return error for invalid characters', () {
        expect(
            CategoryValidators.validateCategoryName('Food<script>'), isNotNull);
        expect(CategoryValidators.validateCategoryName('Rent;'), isNotNull);
      });

      test('should return error for SQL keywords', () {
        expect(
            CategoryValidators.validateCategoryName('DROP TABLE'), isNotNull);
        expect(
            CategoryValidators.validateCategoryName('delete from'), isNotNull);
        expect(
            CategoryValidators.validateCategoryName('INSERT INTO'), isNotNull);
      });
    });

    group('validateBudget', () {
      test('should return null for valid budgets', () {
        expect(CategoryValidators.validateBudget('0'), isNull);
        expect(CategoryValidators.validateBudget('100'), isNull);
        expect(CategoryValidators.validateBudget('1000.50'), isNull);
      });

      test('should return error for null or empty', () {
        expect(CategoryValidators.validateBudget(null), isNotNull);
        expect(CategoryValidators.validateBudget(''), isNotNull);
        expect(CategoryValidators.validateBudget('   '), isNotNull);
      });

      test('should return error for invalid number format', () {
        expect(CategoryValidators.validateBudget('abc'), isNotNull);
        expect(CategoryValidators.validateBudget('12.34.56'), isNotNull);
      });

      test('should return error for negative budgets', () {
        expect(CategoryValidators.validateBudget('-10'), isNotNull);
        expect(CategoryValidators.validateBudget('-0.01'), isNotNull);
      });

      test('should accept zero budget', () {
        expect(CategoryValidators.validateBudget('0'), isNull);
      });

      test('should return error for budgets exceeding maximum', () {
        expect(CategoryValidators.validateBudget('10000001'), isNotNull);
      });

      test('should return error for more than 2 decimal places', () {
        expect(CategoryValidators.validateBudget('10.123'), isNotNull);
      });
    });

    group('validateColor', () {
      test('should return null for valid color values', () {
        expect(CategoryValidators.validateColor(0xFF000000), isNull);
        expect(CategoryValidators.validateColor(0xFFFFFFFF), isNull);
        expect(CategoryValidators.validateColor(0xFF4CAF50), isNull);
      });

      test('should return error for null', () {
        expect(CategoryValidators.validateColor(null), isNotNull);
      });

      test('should return error for invalid color values', () {
        expect(CategoryValidators.validateColor(-1), isNotNull);
        expect(CategoryValidators.validateColor(0xFFFFFFFF + 1), isNotNull);
      });
    });

    group('validateIconCodePoint', () {
      test('should return null for valid icon code points', () {
        expect(CategoryValidators.validateIconCodePoint('0xe3e7'), isNull);
        expect(CategoryValidators.validateIconCodePoint('123'), isNull);
      });

      test('should return error for null or empty', () {
        expect(CategoryValidators.validateIconCodePoint(null), isNotNull);
        expect(CategoryValidators.validateIconCodePoint(''), isNotNull);
        expect(CategoryValidators.validateIconCodePoint('   '), isNotNull);
      });

      test('should return error for invalid length', () {
        final longIcon = '0' * 11;
        expect(CategoryValidators.validateIconCodePoint(longIcon), isNotNull);
      });
    });

    group('isValidBudgetValue', () {
      test('should return true for valid budgets', () {
        expect(CategoryValidators.isValidBudgetValue(0), isTrue);
        expect(CategoryValidators.isValidBudgetValue(100), isTrue);
        expect(CategoryValidators.isValidBudgetValue(9999999.99), isTrue);
      });

      test('should return false for negative budgets', () {
        expect(CategoryValidators.isValidBudgetValue(-10), isFalse);
      });

      test('should return false for budgets exceeding maximum', () {
        expect(CategoryValidators.isValidBudgetValue(10000001), isFalse);
      });
    });
  });
}
