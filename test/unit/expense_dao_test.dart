// QA Verified: Delete + Update Expense Flow
import 'package:drift/native.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/database/daos/expense_dao.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';

void main() {
  late AppDatabase database;
  late ExpenseDao dao;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    dao = ExpenseDao(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('deleteExpense removes the expense from the database', () async {
    final expense = ExpensesCompanion(
      amount: const Value(100.0),
      description: const Value('Test Expense'),
      date: Value(DateTime.now()),
      categoryId: const Value(
          1), // Assuming category 1 exists or FK is disabled for test
    );

    // We might need to insert a category first if FK is enforced
    // But for unit test with in-memory, we can disable FK or insert category
    // Let's try to insert category first to be safe
    await database.categoryDao.insertCategory(
      CategoriesCompanion(
        name: const Value('Test Category'),
        iconCodePoint: const Value('123'),
        color: const Value(0xFF000000),
        budget: const Value(1000.0),
      ),
    );

    final id = await dao.insertExpense(expense);
    final allExpensesBefore = await dao.getAllExpenses();
    expect(allExpensesBefore.length, 1);

    await dao.deleteExpense(id);
    final allExpensesAfter = await dao.getAllExpenses();
    expect(allExpensesAfter.isEmpty, true);
  });

  test('updateExpense modifies the expense in the database', () async {
    await database.categoryDao.insertCategory(
      CategoriesCompanion(
        name: const Value('Test Category'),
        iconCodePoint: const Value('123'),
        color: const Value(0xFF000000),
        budget: const Value(1000.0),
      ),
    );

    final expense = ExpensesCompanion(
      amount: const Value(100.0),
      description: const Value('Original Description'),
      date: Value(DateTime.now()),
      categoryId: const Value(1),
    );

    final id = await dao.insertExpense(expense);
    final original = (await dao.getAllExpenses()).first;

    final updatedExpense = original.copyWith(
      description: 'Updated Description',
      amount: 200.0,
    );

    await dao.updateExpense(updatedExpense);
    final retrieved = (await dao.getAllExpenses()).first;

    expect(retrieved.description, 'Updated Description');
    expect(retrieved.amount, 200.0);
  });
}
