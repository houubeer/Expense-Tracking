import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/database/i_database.dart';
import 'package:expense_tracking_desktop_app/features/expenses/repositories/i_expense_repository.dart';
import 'package:expense_tracking_desktop_app/features/budget/repositories/i_category_reader.dart';
import 'package:expense_tracking_desktop_app/features/budget/repositories/i_category_budget_manager.dart';
import 'package:expense_tracking_desktop_app/features/expenses/services/i_expense_service.dart';
import 'package:expense_tracking_desktop_app/services/logger_service.dart';
import 'package:expense_tracking_desktop_app/core/exceptions.dart';

/// Service layer for expense-related business logic
/// Handles expense operations and category spent updates with transactional safety
class ExpenseService implements IExpenseService {
  final IExpenseRepository _expenseRepository;
  final ICategoryReader _categoryReader;
  final ICategoryBudgetManager _categoryBudgetManager;
  final IDatabase _database;
  final _logger = LoggerService.instance;

  ExpenseService(
    this._expenseRepository,
    this._categoryReader,
    this._categoryBudgetManager,
    this._database,
  );

  @override
  Future<int> createExpense(ExpensesCompanion expense) async {
    try {
      _logger.info('Creating expense: ${expense.description.value}');
      return await _database.transaction(() async {
        // Insert the expense
        final expenseId = await _expenseRepository.insertExpense(expense);

        // Update category spent amount
        if (expense.categoryId.present) {
          final categoryId = expense.categoryId.value;
          final amount = expense.amount.value;

          final category = await _categoryReader.getCategoryById(categoryId);
          if (category != null) {
            await _categoryBudgetManager.updateCategorySpent(
              category.id,
              category.spent + amount,
            );
          } else {
            _logger.warning('Category not found for expense creation: $categoryId');
          }
        }

        return expenseId;
      });
    } catch (e, stackTrace) {
      _logger.error('Failed to create expense', error: e, stackTrace: stackTrace);
      throw DatabaseException('Failed to create expense', originalError: e);
    }
  }

  @override
  Future<void> updateExpense(
    Expense oldExpense,
    Expense newExpense,
  ) async {
    try {
      _logger.info('Updating expense: ${oldExpense.id}');
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
          if (oldCategory != null) {
            await _categoryBudgetManager.updateCategorySpent(
              oldCategory.id,
              (oldCategory.spent - oldAmount).clamp(0.0, double.infinity),
            );
          }

          // Add to new category
          final newCategory =
              await _categoryReader.getCategoryById(newCategoryId);
          if (newCategory != null) {
            await _categoryBudgetManager.updateCategorySpent(
              newCategory.id,
              newCategory.spent + newAmount,
            );
          }
        } else if (oldAmount != newAmount) {
          // Same category but amount changed
          final category = await _categoryReader.getCategoryById(newCategoryId);
          if (category != null) {
            final amountDiff = newAmount - oldAmount;
            await _categoryBudgetManager.updateCategorySpent(
              category.id,
              (category.spent + amountDiff).clamp(0.0, double.infinity),
            );
          }
        }
      });
    } catch (e, stackTrace) {
      _logger.error('Failed to update expense', error: e, stackTrace: stackTrace);
      throw DatabaseException('Failed to update expense', originalError: e);
    }
  }

  @override
  Future<void> deleteExpense(Expense expense) async {
    try {
      _logger.info('Deleting expense: ${expense.id}');
      await _database.transaction(() async {
        // Delete the expense
        await _expenseRepository.deleteExpense(expense.id);

        // Update category spent (subtract the deleted amount)
        final category =
            await _categoryReader.getCategoryById(expense.categoryId);
        if (category != null) {
          await _categoryBudgetManager.updateCategorySpent(
            category.id,
            (category.spent - expense.amount).clamp(0.0, double.infinity),
          );
        }
      });
    } catch (e, stackTrace) {
      _logger.error('Failed to delete expense', error: e, stackTrace: stackTrace);
      throw DatabaseException('Failed to delete expense', originalError: e);
    }
  }

  @override
  Stream<List<ExpenseWithCategory>> watchExpensesWithCategory() {
    return _expenseRepository.watchExpensesWithCategory();
  }
}
