import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/expenses_table.dart';
import '../tables/categories_table.dart';
import 'package:expense_tracking_desktop_app/services/connectivity_service.dart';
import 'package:expense_tracking_desktop_app/services/logger_service.dart';

part 'expense_dao.g.dart';

/// Data Access Object for managing Expense-related database operations.
///
/// This class provides methods to:
/// - CRUD operations for [Expense] entities.
/// - Filtered querying of expenses with category information.
/// - Aggregation of expenses by category for budgeting.
///
/// It uses [ConnectivityService] to track the success/failure of operations
/// and [LoggerService] for detailed logging.
@DriftAccessor(tables: [Expenses, Categories])
class ExpenseDao extends DatabaseAccessor<AppDatabase> with _$ExpenseDaoMixin {
  final ConnectivityService? _connectivityService;
  final _logger = LoggerService.instance;

  ExpenseDao(super.db, [this._connectivityService]);

  /// Watches all expenses ordered by date (descending).
  ///
  /// Returns a [Stream] of [List<Expense>].
  Stream<List<Expense>> watchAllExpenses() {
    return (select(expenses)
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)
          ]))
        .watch();
  }

  /// Watches expenses with their associated category, applying optional filters.
  ///
  /// [searchQuery] - Filters by expense description or category name (case-insensitive).
  /// [categoryId] - Filters by a specific category ID.
  /// [date] - Filters by a specific date (matches the entire day).
  ///
  /// Returns a [Stream] of [List<ExpenseWithCategory>] ordered by date (descending).
  Stream<List<ExpenseWithCategory>> watchExpensesWithCategory({
    String? searchQuery,
    int? categoryId,
    DateTime? date,
  }) {
    final query = select(expenses).join([
      innerJoin(categories, categories.id.equalsExp(expenses.categoryId)),
    ]);

    // Apply filters
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query.where(expenses.description.like('%$searchQuery%') |
          categories.name.like('%$searchQuery%'));
    }

    if (categoryId != null) {
      query.where(expenses.categoryId.equals(categoryId));
    }

    if (date != null) {
      // Filter by day
      final start = DateTime(date.year, date.month, date.day);
      final end = start.add(const Duration(days: 1));
      query.where(expenses.date.isBiggerOrEqualValue(start) &
          expenses.date.isSmallerThanValue(end));
    }

    // Order by date descending
    query.orderBy([OrderingTerm(expression: expenses.date, mode: OrderingMode.desc)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return ExpenseWithCategory(
          expense: row.readTable(expenses),
          category: row.readTable(categories),
        );
      }).toList();
    });
  }

  /// Retrieves all expenses from the database.
  ///
  /// Returns a [Future] containing a [List<Expense>].
  /// Logs the operation and updates connectivity status.
  /// Throws generic exceptions if the database operation fails.
  Future<List<Expense>> getAllExpenses() async {
    try {
      _logger.debug('ExpenseDao: getAllExpenses called');
      final result = await select(expenses).get();
      _connectivityService?.markSuccessfulOperation();
      return result;
    } catch (e, stackTrace) {
      _logger.error('ExpenseDao: getAllExpenses failed',
          error: e, stackTrace: stackTrace);
      _connectivityService?.handleConnectionFailure(e.toString());
      rethrow;
    }
  }

  /// Inserts a new expense into the database.
  ///
  /// [expense] - The [ExpensesCompanion] containing the data to insert.
  ///
  /// Returns the ID of the inserted expense.
  /// Note: This is a pure CRUD operation. Business logic (like updating category budgets)
  /// should be handled by the Service layer.
  Future<int> insertExpense(ExpensesCompanion expense) async {
    try {
      final id = await into(expenses).insert(expense);
      _connectivityService?.markSuccessfulOperation();
      return id;
    } catch (e, stackTrace) {
      _logger.error('ExpenseDao: insertExpense failed',
          error: e, stackTrace: stackTrace);
      _connectivityService?.handleConnectionFailure(e.toString());
      rethrow;
    }
  }

  /// Updates an existing expense in the database.
  ///
  /// [expense] - The [Expense] object with updated values.
  ///
  /// Returns `true` if the update was successful.
  Future<bool> updateExpense(Expense expense) async {
    try {
      final result = await update(expenses).replace(expense);
      _connectivityService?.markSuccessfulOperation();
      return result;
    } catch (e, stackTrace) {
      _logger.error('ExpenseDao: updateExpense failed',
          error: e, stackTrace: stackTrace);
      _connectivityService?.handleConnectionFailure(e.toString());
      rethrow;
    }
  }

  /// Deletes an expense from the database by its ID.
  ///
  /// [id] - The unique identifier of the expense to delete.
  ///
  /// Returns the number of rows affected (should be 1).
  Future<int> deleteExpense(int id) async {
    try {
      final result = await (delete(expenses)..where((e) => e.id.equals(id))).go();
      _connectivityService?.markSuccessfulOperation();
      return result;
    } catch (e, stackTrace) {
      _logger.error('ExpenseDao: deleteExpense failed',
          error: e, stackTrace: stackTrace);
      _connectivityService?.handleConnectionFailure(e.toString());
      rethrow;
    }
  }

  /// Watches the total sum of expenses grouped by category.
  ///
  /// Returns a [Stream] of a Map where the key is the Category ID and the value is the total amount.
  /// Useful for real-time budget tracking.
  Stream<Map<int, double>> watchExpensesSumByCategory() {
    final query = selectOnly(expenses)
      ..addColumns([expenses.categoryId, expenses.amount.sum()]);
    query.groupBy([expenses.categoryId]);

    return query.watch().map((rows) {
      final result = <int, double>{};
      for (final row in rows) {
        final categoryId = row.read(expenses.categoryId);
        final sum = row.read(expenses.amount.sum()) ?? 0.0;
        if (categoryId != null) {
          result[categoryId] = sum;
        }
      }
      return result;
    });
  }

  /// Retrieves the total sum of expenses grouped by category (one-time query).
  ///
  /// Returns a [Future] of a Map where the key is the Category ID and the value is the total amount.
  Future<Map<int, double>> getExpensesSumByCategory() async {
    try {
      final query = selectOnly(expenses)
        ..addColumns([expenses.categoryId, expenses.amount.sum()]);
      query.groupBy([expenses.categoryId]);

      final rows = await query.get();
      final result = <int, double>{};
      for (final row in rows) {
        final categoryId = row.read(expenses.categoryId);
        final sum = row.read(expenses.amount.sum()) ?? 0.0;
        if (categoryId != null) {
          result[categoryId] = sum;
        }
      }
      _connectivityService?.markSuccessfulOperation();
      return result;
    } catch (e) {
      _connectivityService?.handleConnectionFailure(e.toString());
      rethrow;
    }
  }
}

class ExpenseWithCategory {
  final Expense expense;
  final Category category;

  ExpenseWithCategory({required this.expense, required this.category});
}
