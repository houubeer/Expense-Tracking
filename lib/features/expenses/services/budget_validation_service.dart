import 'package:expense_tracking_desktop_app/features/budget/repositories/i_category_repository.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';

/// Budget validation service
///
/// Validates expenses against category budgets before submission.
/// This is a CRITICAL business rule - prevents budget overruns.
class BudgetValidationService {
  final ICategoryRepository _categoryRepository;

  BudgetValidationService(this._categoryRepository);

  /// Validate if an expense can be added within budget constraints
  ///
  /// Returns null if validation passes, error message if it fails.
  ///
  /// [amount] The expense amount to validate
  /// [categoryId] The category ID for the expense
  Future<String?> validateExpenseAgainstBudget(
    double amount,
    int categoryId,
  ) async {
    // Get category to check budget
    final category = await _categoryRepository.getCategoryById(categoryId);

    if (category == null) {
      return 'Category not found';
    }

    // Calculate remaining budget
    final remainingBudget = category.budget - category.spent;

    // Check if expense exceeds available budget
    if (amount > remainingBudget) {
      // Format error message with actual values
      return AppStrings.errBudgetExceededDetails
          .replaceAll('{amount}', '${amount.toStringAsFixed(2)} ${AppStrings.currency}')
          .replaceAll('{remaining}', '${remainingBudget.toStringAsFixed(2)} ${AppStrings.currency}');
    }

    // Validation passed
    return null;
  }

  /// Get available budget for a category
  ///
  /// Returns the remaining budget amount
  Future<double> getAvailableBudget(int categoryId) async {
    final category = await _categoryRepository.getCategoryById(categoryId);
    if (category == null) {
      return 0.0;
    }
    return category.budget - category.spent;
  }

  /// Check if category has sufficient budget
  ///
  /// Returns true if the category has enough budget, false otherwise
  Future<bool> hasSufficientBudget(double amount, int categoryId) async {
    final errorMessage = await validateExpenseAgainstBudget(amount, categoryId);
    return errorMessage == null;
  }
}
