import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/database/i_database.dart';
import 'package:expense_tracking_desktop_app/features/expenses/repositories/i_expense_repository.dart';
import 'package:expense_tracking_desktop_app/features/budget/repositories/i_category_reader.dart';
import 'package:expense_tracking_desktop_app/features/budget/repositories/i_category_budget_manager.dart';
import 'package:expense_tracking_desktop_app/features/expenses/services/i_expense_service.dart';

/// Service layer for expense-related business logic
/// Handles expense operations and category spent updates with transactional safety
/// Now depends only on specific interfaces it needs (ISP compliance)
class ExpenseService implements IExpenseService {
  final IExpenseRepository _expenseRepository;
  final ICategoryReader _categoryReader;
  final ICategoryBudgetManager _categoryBudgetManager;
  final IDatabase _database;

  ExpenseService(
    this._expenseRepository,
    this._categoryReader,
    this._categoryBudgetManager,
    this._database,
  );

  @override
  Future<int> createExpense(ExpensesCompanion expense) async {
    try {
      return await _database.transaction(() async {
        // Insert the expense
        final expenseId = await _expenseRepository.insertExpense(expense);

        // Update category spent amount
        if (expense.categoryId.present) {
          final categoryId = expense.categoryId.value;
          final amount = expense.amount.value;

          final category = await _categoryReader.getCategoryById(categoryId);
          if (category == null) {
            throw Exception('Category not found with id: $categoryId');
          }

          await _categoryBudgetManager.updateCategorySpent(
            category.id,
            category.spent + amount,
            category.version,
          );
        }

        return expenseId;
      });
    } catch (e) {
      throw Exception('Failed to create expense: $e');
    }
  }

  @override
  Future<void> updateExpense(
    Expense oldExpense,
    Expense newExpense,
  ) async {
    try {
      await _database.transaction(() async {
        // Update the expense
        await _expenseRepository.updateExpense(newExpense);

        final oldAmount = oldExpense.amount;
        final newAmount = newExpense.amount;
        final oldCategoryId = oldExpense.categoryId;
        final newCategoryId = newExpense.categoryId;

        // If category changed, update both old and new categories
        if (oldCategoryId != newCategoryId) {
          // Subtract from old category
          final oldCategory =
              await _categoryReader.getCategoryById(oldCategoryId);
          if (oldCategory == null) {
            throw Exception('Old category not found with id: $oldCategoryId');
          }
          await _categoryBudgetManager.updateCategorySpent(
            oldCategory.id,
            (oldCategory.spent - oldAmount).clamp(0.0, double.infinity),
            oldCategory.version,
          );

          // Add to new category
          final newCategory =
              await _categoryReader.getCategoryById(newCategoryId);
          if (newCategory == null) {
            throw Exception('New category not found with id: $newCategoryId');
          }
          await _categoryBudgetManager.updateCategorySpent(
            newCategory.id,
            newCategory.spent + newAmount,
            newCategory.version,
          );
        } else if (oldAmount != newAmount) {
          // Same category but amount changed
          final category = await _categoryReader.getCategoryById(newCategoryId);
          if (category == null) {
            throw Exception('Category not found with id: $newCategoryId');
          }
          final amountDiff = newAmount - oldAmount;
          await _categoryBudgetManager.updateCategorySpent(
            category.id,
            (category.spent + amountDiff).clamp(0.0, double.infinity),
            category.version,
          );
        }
      });
    } catch (e) {
      throw Exception('Failed to update expense: $e');
    }
  }

  @override
  Future<void> deleteExpense(Expense expense) async {
    try {
      await _database.transaction(() async {
        // Delete the expense
        await _expenseRepository.deleteExpense(expense.id);

        // Update category spent (subtract the deleted amount)
        final category =
            await _categoryReader.getCategoryById(expense.categoryId);
        if (category == null) {
          throw Exception('Category not found with id: ${expense.categoryId}');
        }
        await _categoryBudgetManager.updateCategorySpent(
          category.id,
          (category.spent - expense.amount).clamp(0.0, double.infinity),
          category.version,
        );
      });
    } catch (e) {
      throw Exception('Failed to delete expense: $e');
    }
  }

  @override
  Stream<List<ExpenseWithCategory>> watchExpensesWithCategory() {
    return _expenseRepository.watchExpensesWithCategory();
  }
}
