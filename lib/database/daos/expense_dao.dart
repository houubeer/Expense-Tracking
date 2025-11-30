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

  // Insert expense and update category spent
  Future<int> insertExpense(ExpensesCompanion expense) async {
    try {
      // Validate amount
      if (expense.amount.present) {
        final amount = expense.amount.value;
        if (amount <= 0) {
          throw Exception('Amount must be greater than 0, got: $amount');
        }
        if (amount > 1000000000) {
          throw Exception('Amount is too large: $amount');
        }
      }
      
      // Validate date
      if (expense.date.present) {
        final date = expense.date.value;
        final now = DateTime.now();
        final futureLimit = DateTime(now.year + 1, now.month, now.day);
        final pastLimit = DateTime(now.year - 10, now.month, now.day);
        
        if (date.isAfter(futureLimit)) {
          throw Exception('Date cannot be more than 1 year in the future');
        }
        if (date.isBefore(pastLimit)) {
          throw Exception('Date cannot be more than 10 years in the past');
        }
      }
      
      final id = await into(expenses).insert(expense);

      // Update category spent amount
      if (expense.categoryId.present && expense.amount.present) {
        final categoryId = expense.categoryId.value;
        final amount = expense.amount.value;

        final category = await (select(categories)
              ..where((c) => c.id.equals(categoryId)))
            .getSingleOrNull();
        if (category != null) {
          final newSpent = category.spent + amount;
          await (update(categories)..where((c) => c.id.equals(categoryId)))
              .write(CategoriesCompanion(spent: Value(newSpent)));
        }
      }

      return id;
    } catch (e) {
      throw Exception('Database error: Failed to insert expense - $e');
    }
  }

  // Update expense and adjust category spent
  Future<bool> updateExpense(Expense expense) async {
    try {
      // Validate amount
      if (expense.amount <= 0) {
        throw Exception('Amount must be greater than 0, got: ${expense.amount}');
      }
      if (expense.amount > 1000000000) {
        throw Exception('Amount is too large: ${expense.amount}');
      }
      
      // Validate date
      final now = DateTime.now();
      final futureLimit = DateTime(now.year + 1, now.month, now.day);
      final pastLimit = DateTime(now.year - 10, now.month, now.day);
      
      if (expense.date.isAfter(futureLimit)) {
        throw Exception('Date cannot be more than 1 year in the future');
      }
      if (expense.date.isBefore(pastLimit)) {
        throw Exception('Date cannot be more than 10 years in the past');
      }
      
      // Get the old expense to calculate the difference
      final oldExpense = await (select(expenses)
            ..where((e) => e.id.equals(expense.id)))
          .getSingleOrNull();
      if (oldExpense == null) {
        throw Exception('Expense not found with id: ${expense.id}');
      }

      final result = await update(expenses).replace(expense);

      if (result) {
        // If category changed, update both old and new categories
        if (oldExpense.categoryId != expense.categoryId) {
          // Decrease old category spent
          final oldCategory = await (select(categories)
                ..where((c) => c.id.equals(oldExpense.categoryId)))
              .getSingleOrNull();
          if (oldCategory != null) {
            final newSpent = (oldCategory.spent - oldExpense.amount)
                .clamp(0.0, double.infinity);
            await (update(categories)
                  ..where((c) => c.id.equals(oldExpense.categoryId)))
                .write(CategoriesCompanion(spent: Value(newSpent)));
          }

          // Increase new category spent
          final newCategory = await (select(categories)
                ..where((c) => c.id.equals(expense.categoryId)))
              .getSingleOrNull();
          if (newCategory != null) {
            final newSpent = newCategory.spent + expense.amount;
            await (update(categories)
                  ..where((c) => c.id.equals(expense.categoryId)))
                .write(CategoriesCompanion(spent: Value(newSpent)));
          }
        } else {
          // Same category, just update the difference
          final amountDiff = expense.amount - oldExpense.amount;
          if (amountDiff != 0) {
            final category = await (select(categories)
                  ..where((c) => c.id.equals(expense.categoryId)))
                .getSingleOrNull();
            if (category != null) {
              final newSpent =
                  (category.spent + amountDiff).clamp(0.0, double.infinity);
              await (update(categories)
                    ..where((c) => c.id.equals(expense.categoryId)))
                  .write(CategoriesCompanion(spent: Value(newSpent)));
            }
          }
        }
      }

      return result;
    } catch (e) {
      throw Exception('Database error: Failed to update expense - $e');
    }
  }

  // Delete expense and update category spent
  Future<int> deleteExpense(int id) async {
    try {
      // Get the expense first to know which category and amount
      final expense = await (select(expenses)..where((e) => e.id.equals(id)))
          .getSingleOrNull();
      if (expense == null) {
        throw Exception('Expense not found with id: $id');
      }

      // Delete the expense
      final result = await (delete(expenses)..where((e) => e.id.equals(id))).go();

      // Update category spent amount
      if (result > 0) {
        final category = await (select(categories)
              ..where((c) => c.id.equals(expense.categoryId)))
            .getSingleOrNull();
        if (category != null) {
          final newSpent =
              (category.spent - expense.amount).clamp(0.0, double.infinity);
          await (update(categories)
                ..where((c) => c.id.equals(expense.categoryId)))
              .write(CategoriesCompanion(spent: Value(newSpent)));
        }
      }

      return result;
    } catch (e) {
      throw Exception('Database error: Failed to delete expense - $e');
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
