import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/database/daos/expense_dao.dart';
import 'package:expense_tracking_desktop_app/features/expenses/repositories/expense_repository.dart';
import 'package:expense_tracking_desktop_app/features/budget/repositories/category_repository.dart';

/// Service layer for expense-related business logic
/// Handles expense operations and category spent updates
class ExpenseService {
  final ExpenseRepository _expenseRepository;
  final CategoryRepository _categoryRepository;

  ExpenseService(this._expenseRepository, this._categoryRepository);

  /// Create a new expense and update category spent
  Future<int> createExpense(ExpensesCompanion expense) async {
    // Insert the expense
    final expenseId = await _expenseRepository.insertExpense(expense);

    // Update category spent amount
    if (expense.categoryId.present) {
      final categoryId = expense.categoryId.value;
      final amount = expense.amount.value;

      final category = await _categoryRepository.getCategoryById(categoryId);
      if (category != null) {
        await _categoryRepository.updateCategorySpent(
          category.id,
          category.spent + amount,
        );
      }
    }

    return expenseId;
  }

  /// Update an existing expense and recalculate category spent
  Future<void> updateExpense(
    Expense oldExpense,
    Expense newExpense,
  ) async {
    // Update the expense
    await _expenseRepository.updateExpense(newExpense);

    final oldAmount = oldExpense.amount;
    final newAmount = newExpense.amount;
    final oldCategoryId = oldExpense.categoryId;
    final newCategoryId = newExpense.categoryId;

    // If category changed, update both old and new categories
    if (oldCategoryId != newCategoryId) {
      // Subtract from old category
      final oldCategory = await _categoryRepository.getCategoryById(oldCategoryId);
      if (oldCategory != null) {
        await _categoryRepository.updateCategorySpent(
          oldCategory.id,
          (oldCategory.spent - oldAmount).clamp(0.0, double.infinity),
        );
      }

      // Add to new category
      final newCategory = await _categoryRepository.getCategoryById(newCategoryId);
      if (newCategory != null) {
        await _categoryRepository.updateCategorySpent(
          newCategory.id,
          newCategory.spent + newAmount,
        );
      }
    } else if (oldAmount != newAmount) {
      // Same category but amount changed
      final category = await _categoryRepository.getCategoryById(newCategoryId);
      if (category != null) {
        final amountDiff = newAmount - oldAmount;
        await _categoryRepository.updateCategorySpent(
          category.id,
          (category.spent + amountDiff).clamp(0.0, double.infinity),
        );
      }
    }
  }

  /// Delete an expense and update category spent
  Future<void> deleteExpense(Expense expense) async {
    // Delete the expense
    await _expenseRepository.deleteExpense(expense.id);

    // Update category spent (subtract the deleted amount)
    final category = await _categoryRepository.getCategoryById(expense.categoryId);
    if (category != null) {
      await _categoryRepository.updateCategorySpent(
        category.id,
        (category.spent - expense.amount).clamp(0.0, double.infinity),
      );
    }
  }

  // Delegate read operations to repository
  Stream<List<ExpenseWithCategory>> watchExpensesWithCategory() {
    return _expenseRepository.watchExpensesWithCategory();
  }
}
