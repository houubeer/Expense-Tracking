import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/expenses_table.dart';

part 'expense_dao.g.dart';

@DriftAccessor(tables: [Expenses])
class ExpenseDao extends DatabaseAccessor<AppDatabase> with _$ExpenseDaoMixin {
  ExpenseDao(AppDatabase db) : super(db);

  // Get all expenses
  Future<List<Expense>> getAllExpenses() => select(expenses).get();

  // Get expenses by category
  Future<List<Expense>> getExpensesByCategory(int categoryId) =>
      (select(expenses)..where((e) => e.categoryId.equals(categoryId))).get();

  // Get expenses for a date range
  Future<List<Expense>> getExpensesByDateRange(DateTime start, DateTime end) =>
      (select(expenses)
            ..where((e) => e.date.isBetweenValues(start, end))
            ..orderBy([(e) => OrderingTerm.desc(e.date)]))
          .get();

  // Get recent expenses
  Future<List<Expense>> getRecentExpenses({int limit = 10}) => (select(expenses)
        ..orderBy([(e) => OrderingTerm.desc(e.createdAt)])
        ..limit(limit))
      .get();

  // Add expense
  Future<int> addExpense(ExpensesCompanion expense) =>
      into(expenses).insert(expense);

  // Update expense (updates updatedAt automatically)
  Future<bool> updateExpense(Expense expense) async {
    final updatedExpense = expense.copyWith(updatedAt: DateTime.now());
    return update(expenses).replace(updatedExpense);
  }

  // Delete expense
  Future<int> deleteExpense(int id) =>
      (delete(expenses)..where((e) => e.id.equals(id))).go();

  // Get total spent by category
  Future<double> getTotalSpentByCategory(int categoryId) async {
    final query = selectOnly(expenses)
      ..addColumns([expenses.amount.sum()])
      ..where(expenses.categoryId.equals(categoryId));

    final result = await query.getSingleOrNull();
    return result?.read(expenses.amount.sum()) ?? 0.0;
  }

  // Get total spent in date range
  Future<double> getTotalSpentInDateRange(DateTime start, DateTime end) async {
    final query = selectOnly(expenses)
      ..addColumns([expenses.amount.sum()])
      ..where(expenses.date.isBetweenValues(start, end));

    final result = await query.getSingleOrNull();
    return result?.read(expenses.amount.sum()) ?? 0.0;
  }

  // Watch all expenses (stream)
  Stream<List<Expense>> watchAllExpenses() => select(expenses).watch();

  // Watch expenses by category (stream)
  Stream<List<Expense>> watchExpensesByCategory(int categoryId) =>
      (select(expenses)..where((e) => e.categoryId.equals(categoryId))).watch();
}
