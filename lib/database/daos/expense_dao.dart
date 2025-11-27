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
          ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]))
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

  // Get expense by id
  Future<Expense?> getExpenseById(int id) =>
      (select(expenses)..where((e) => e.id.equals(id))).getSingleOrNull();
}

class ExpenseWithCategory {
  final Expense expense;
  final Category category;

  ExpenseWithCategory({required this.expense, required this.category});
}
