import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/database/i_database.dart';
import 'package:expense_tracking_desktop_app/features/expenses/repositories/i_expense_repository.dart';
import 'package:expense_tracking_desktop_app/features/budget/repositories/i_category_reader.dart';
import 'package:expense_tracking_desktop_app/features/budget/repositories/i_category_budget_manager.dart';
import 'package:expense_tracking_desktop_app/features/expenses/services/i_expense_service.dart';
import 'package:expense_tracking_desktop_app/services/logger_service.dart';
import 'package:expense_tracking_desktop_app/core/exceptions.dart';

/// Service layer for expense-related business logic.
///
/// Orchestrates expense operations with transactional safety, ensuring database
/// consistency when creating, updating, or deleting expenses with associated
/// category budget updates.
///
/// **Responsibilities:**
/// - Create expenses and update category budgets atomically
/// - Update expenses with proper budget recalculation
/// - Delete expenses and adjust category spent amounts
/// - Ensure all operations are wrapped in transactions
///
/// **Transaction Management:**
/// All operations that modify both expenses and category budgets are wrapped
/// in database transactions to maintain data consistency. If any step fails,
/// the entire operation is rolled back.
///
/// Example:
/// ```dart
/// final service = ref.read(expenseServiceProvider);
/// await service.createExpense(ExpensesCompanion(
///   description: Value('Groceries'),
///   amount: Value(50.0),
///   categoryId: Value(1),
/// ));
/// ```
class ExpenseService implements IExpenseService {
  final IExpenseRepository _expenseRepository;
  final ICategoryReader _categoryReader;
  final ICategoryBudgetManager _categoryBudgetManager;
  final IDatabase _database;
  final _logger = LoggerService.instance;

  /// Creates a new [ExpenseService] instance.
  ///
  /// [_expenseRepository] Repository for expense data access.
  /// [_categoryReader] Reader for querying category information.
  /// [_categoryBudgetManager] Manager for updating category budgets.
  /// [_database] Database interface for transaction support.
  ExpenseService(
    this._expenseRepository,
    this._categoryReader,
    this._categoryBudgetManager,
    this._database,
  );

  /// Creates a new expense and updates the associated category's spent amount.
  ///
  /// This operation is executed within a transaction to ensure atomicity. If the
  /// expense is successfully inserted, the category's spent amount is incremented
  /// by the expense amount. If any step fails, the entire operation is rolled back.
  ///
  /// **Process:**
  /// 1. Insert expense into database
  /// 2. Retrieve category information
  /// 3. Update category spent amount (spent + amount)
  ///
  /// [expense] The expense data to create.
  ///
  /// Returns the ID of the newly created expense.
  ///
  /// Throws [DatabaseException] if the operation fails.
  ///
  /// Example:
  /// ```dart
  /// final id = await service.createExpense(ExpensesCompanion(
  ///   description: Value('Coffee'),
  ///   amount: Value(5.0),
  ///   categoryId: Value(3),
  /// ));
  /// print('Created expense with ID: $id');
  /// ```
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
              category.version,
            );
          } else {
            _logger.warning(
                'Category not found for expense creation: $categoryId');
          }
        }

        return expenseId;
      });
    } catch (e, stackTrace) {
      _logger.error('Failed to create expense',
          error: e, stackTrace: stackTrace);
      throw DatabaseException('Failed to create expense', originalError: e);
    }
  }

  /// Updates an existing expense and recalculates category spent amounts.
  ///
  /// This operation handles three scenarios within a transaction:
  /// - **Category changed**: Subtract from old category, add to new category
  /// - **Same category, amount changed**: Adjust category spent by difference
  /// - **No budget impact**: Only update expense data
  ///
  /// [oldExpense] The expense before modification.
  /// [newExpense] The expense with updated values.
  ///
  /// Throws [DatabaseException] if the operation fails.
  ///
  /// Example:
  /// ```dart
  /// await service.updateExpense(
  ///   oldExpense,
  ///   oldExpense.copyWith(amount: 75.0),
  /// );
  /// ```
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
              oldCategory.version,
            );
          }

          // Add to new category
          final newCategory =
              await _categoryReader.getCategoryById(newCategoryId);
          if (newCategory != null) {
            await _categoryBudgetManager.updateCategorySpent(
              newCategory.id,
              newCategory.spent + newAmount,
              newCategory.version,
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
              category.version,
            );
          }
        }
      });
    } catch (e, stackTrace) {
      _logger.error('Failed to update expense',
          error: e, stackTrace: stackTrace);
      throw DatabaseException('Failed to update expense', originalError: e);
    }
  }

  /// Deletes an expense and adjusts the category's spent amount.
  ///
  /// This operation is executed within a transaction to ensure atomicity. The
  /// category's spent amount is decremented by the expense amount (clamped to
  /// prevent negative values).
  ///
  /// **Process:**
  /// 1. Delete expense from database
  /// 2. Retrieve category information
  /// 3. Update category spent amount (spent - amount, minimum 0)
  ///
  /// [expense] The expense to delete.
  ///
  /// Throws [DatabaseException] if the operation fails.
  ///
  /// Example:
  /// ```dart
  /// await service.deleteExpense(expense);
  /// print('Expense deleted and budget updated');
  /// ```
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
            category.version,
          );
        }
      });
    } catch (e, stackTrace) {
      _logger.error('Failed to delete expense',
          error: e, stackTrace: stackTrace);
      throw DatabaseException('Failed to delete expense', originalError: e);
    }
  }

  @override
  Stream<List<ExpenseWithCategory>> watchExpensesWithCategory() {
    return _expenseRepository.watchExpensesWithCategory();
  }
}
