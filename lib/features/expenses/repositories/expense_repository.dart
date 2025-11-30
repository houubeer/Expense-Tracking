import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/database/daos/expense_dao.dart';
import 'package:expense_tracking_desktop_app/features/expenses/repositories/i_expense_repository.dart';
import 'package:expense_tracking_desktop_app/features/expenses/services/i_expense_service.dart'
    as domain;

/// Repository implementation for Expense operations.
///
/// Acts as an abstraction layer between the service layer and the data access layer ([ExpenseDao]),
/// converting between domain objects and database objects.
///
/// **Responsibilities:**
/// - Delegates data access operations to the DAO
/// - Maps DAO-level types to domain-level types
/// - Provides a clean interface for the service layer
/// - Does NOT contain business logic (belongs in Service layer)
///
/// **Architecture:**
/// ```
/// Service Layer → ExpenseRepository (this class) → ExpenseDao → Database
/// ```
///
/// Example:
/// ```dart
/// final repository = ref.read(expenseRepositoryProvider);
/// await repository.insertExpense(expenseData);
/// ```
class ExpenseRepository implements IExpenseRepository {
  final ExpenseDao _expenseDao;

  /// Creates an instance of [ExpenseRepository].
  ///
  /// [database] The application database instance.
  ExpenseRepository(AppDatabase database) : _expenseDao = database.expenseDao;

  /// Watches all expenses with their associated category information.
  ///
  /// Returns a stream that emits a new list whenever expenses or categories change.
  /// The stream maps DAO-level [ExpenseWithCategory] objects to domain-level objects.
  ///
  /// This is useful for reactive UI updates.
  ///
  /// Example:
  /// ```dart
  /// repository.watchExpensesWithCategory().listen((expenses) {
  ///   print('Found ${expenses.length} expenses');
  /// });
  /// ```
  @override
  Stream<List<domain.ExpenseWithCategory>> watchExpensesWithCategory() {
    // Map DAO types to domain types
    return _expenseDao.watchExpensesWithCategory().map(
          (daoList) => daoList
              .map(
                (daoExpense) => domain.ExpenseWithCategory(
                  expense: daoExpense.expense,
                  category: daoExpense.category,
                ),
              )
              .toList(),
        );
  }

  /// Inserts a new expense into the database.
  ///
  /// [expense] The expense data to insert.
  ///
  /// Returns the ID of the newly inserted expense.
  ///
  /// Throws [Exception] if the database operation fails.
  ///
  /// Note: This method does NOT update category budgets. Use [ExpenseService.createExpense]
  /// for complete business logic.
  @override
  Future<int> insertExpense(ExpensesCompanion expense) async {
    try {
      return await _expenseDao.insertExpense(expense);
    } catch (e) {
      throw Exception('Failed to insert expense: $e');
    }
  }

  /// Updates an existing expense in the database.
  ///
  /// [expense] The expense with updated data.
  ///
  /// Returns `true` if the update was successful, `false` otherwise.
  ///
  /// Throws [Exception] if the database operation fails.
  ///
  /// Note: This method does NOT handle category budget adjustments. Use
  /// [ExpenseService.updateExpense] for complete business logic.
  @override
  Future<bool> updateExpense(Expense expense) async {
    try {
      return await _expenseDao.updateExpense(expense);
    } catch (e) {
      throw Exception('Failed to update expense: $e');
    }
  }

  /// Deletes an expense from the database by ID.
  ///
  /// [id] The ID of the expense to delete.
  ///
  /// Returns the number of rows affected (should be 1 if successful, 0 if not found).
  ///
  /// Throws [Exception] if the database operation fails.
  ///
  /// Note: This method does NOT update category budgets. Use [ExpenseService.deleteExpense]
  /// for complete business logic that handles budget adjustments.
  @override
  Future<int> deleteExpense(int id) async {
    try {
      return await _expenseDao.deleteExpense(id);
    } catch (e) {
      throw Exception('Failed to delete expense: $e');
    }
  }
}
