import 'package:drift/drift.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/database/daos/expense_dao.dart';
import 'package:expense_tracking_desktop_app/features/expenses/repositories/expense_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'expense_repository_test.mocks.dart';

@GenerateMocks([AppDatabase, ExpenseDao])
void main() {
  late MockAppDatabase mockDatabase;
  late MockExpenseDao mockExpenseDao;
  late ExpenseRepository repository;

  setUp(() {
    mockDatabase = MockAppDatabase();
    mockExpenseDao = MockExpenseDao();

    // Setup the database mock to return the expense dao mock
    when(mockDatabase.expenseDao).thenReturn(mockExpenseDao);

    repository = ExpenseRepository(mockDatabase);
  });

  group('ExpenseRepository', () {
    test('insertExpense delegates to ExpenseDao', () async {
      final expense = ExpensesCompanion(
        amount: Value(100.0),
        description: Value('Test Expense'),
        date: Value(DateTime.now()),
        categoryId: Value(1),
      );

      when(mockExpenseDao.insertExpense(expense)).thenAnswer((_) async => 1);

      final result = await repository.insertExpense(expense);

      verify(mockExpenseDao.insertExpense(expense)).called(1);
      expect(result, 1);
    });

    test('updateExpense delegates to ExpenseDao', () async {
      final expense = Expense(
        id: 1,
        amount: 100.0,
        description: 'Test Expense',
        date: DateTime.now(),
        categoryId: 1,
        createdAt: DateTime.now(),
        isReimbursable: false,
        version: 1,
        isSynced: false,
      );

      when(mockExpenseDao.updateExpense(expense)).thenAnswer((_) async => true);

      final result = await repository.updateExpense(expense);

      verify(mockExpenseDao.updateExpense(expense)).called(1);
      expect(result, true);
    });

    test('deleteExpense delegates to ExpenseDao', () async {
      const id = 1;

      when(mockExpenseDao.deleteExpense(id)).thenAnswer((_) async => 1);

      final result = await repository.deleteExpense(id);

      verify(mockExpenseDao.deleteExpense(id)).called(1);
      expect(result, 1);
    });

    test('watchExpensesWithCategory delegates to ExpenseDao and maps results',
        () async {
      final date = DateTime.now();
      final expense = Expense(
        id: 1,
        amount: 100.0,
        description: 'Test Expense',
        date: date,
        categoryId: 1,
        createdAt: date,
        isReimbursable: false,
        version: 1,
        isSynced: false,
      );
      final category = Category(
        id: 1,
        name: 'Test Category',
        iconCodePoint: '123',
        color: 0xFF000000,
        budget: 1000.0,
        spent: 100.0,
        version: 1,
        createdAt: date,
        isSynced: false,
      );

      final daoResult = [
        ExpenseWithCategory(expense: expense, category: category),
      ];

      when(mockExpenseDao.watchExpensesWithCategory())
          .thenAnswer((_) => Stream.value(daoResult));

      final stream = repository.watchExpensesWithCategory();

      // Use expectLater to avoid multiple listeners
      await expectLater(
        stream,
        emits(predicate<List<dynamic>>((list) {
          return list.length == 1 &&
              list.first.expense.id == expense.id &&
              list.first.category.id == category.id;
        })),
      );
    });
  });
}
