import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/expenses_table.dart';
import '../tables/categories_table.dart';

part 'expense_dao.g.dart';

@DriftAccessor(tables: [Expenses, Categories])
class ExpenseDao extends DatabaseAccessor<AppDatabase> with _$ExpenseDaoMixin {
  ExpenseDao(super.db);

  // Watch all expenses
  Stream<List<Expense>> watchAllExpenses() {
    return (select(expenses)
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)
          ]))
        .watch();
  }

  // Watch expenses with category info
  Stream<List<ExpenseWithCategory>> watchExpensesWithCategory() {
    final query = select(expenses).join([
      innerJoin(categories, categories.id.equalsExp(expenses.categoryId)),
    ]);

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
  Future<List<Expense>> getAllExpenses() => select(expenses).get();

  // Insert expense
  Future<int> insertExpense(ExpensesCompanion expense) =>
      into(expenses).insert(expense);

  // Update expense
  Future<bool> updateExpense(Expense expense) =>
      update(expenses).replace(expense);

  // Delete expense
  Future<int> deleteExpense(int id) =>
      (delete(expenses)..where((e) => e.id.equals(id))).go();

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
    return result;
  }
}

class ExpenseWithCategory {
  final Expense expense;
  final Category category;

  ExpenseWithCategory({required this.expense, required this.category});
}
