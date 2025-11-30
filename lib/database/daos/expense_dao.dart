import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/expenses_table.dart';
import '../tables/categories_table.dart';
import 'package:expense_tracking_desktop_app/services/connectivity_service.dart';
import 'package:expense_tracking_desktop_app/services/logger_service.dart';

part 'expense_dao.g.dart';

@DriftAccessor(tables: [Expenses, Categories])
class ExpenseDao extends DatabaseAccessor<AppDatabase> with _$ExpenseDaoMixin {
  final ConnectivityService? _connectivityService;
  final _logger = LoggerService.instance;

  ExpenseDao(super.db, [this._connectivityService]);

  // Watch all expenses
  Stream<List<Expense>> watchAllExpenses() {
    return (select(expenses)
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)
          ]))
        .watch();
  }

  // Watch expenses with category info and filtering
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

  // Get all expenses
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

  // Insert expense (PURE CRUD ONLY)
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

  // Update expense (PURE CRUD ONLY)
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

  // Delete expense (PURE CRUD ONLY)
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

  // Watch aggregated expenses by category (for budget tracking)
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

  // Get total expenses by category (non-reactive)
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
