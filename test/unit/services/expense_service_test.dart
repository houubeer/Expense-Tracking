import 'package:drift/drift.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/database/i_database.dart';
import 'package:expense_tracking_desktop_app/features/budget/repositories/i_category_budget_manager.dart';
import 'package:expense_tracking_desktop_app/features/budget/repositories/i_category_reader.dart';
import 'package:expense_tracking_desktop_app/features/expenses/repositories/i_expense_repository.dart';
import 'package:expense_tracking_desktop_app/features/expenses/services/expense_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'expense_service_test.mocks.dart';

@GenerateMocks([
  IExpenseRepository,
  ICategoryReader,
  ICategoryBudgetManager,
  IDatabase,
])
void main() {
  late MockIExpenseRepository mockExpenseRepository;
  late MockICategoryReader mockCategoryReader;
  late MockICategoryBudgetManager mockCategoryBudgetManager;
  late MockIDatabase mockDatabase;
  late ExpenseService service;

  setUp(() {
    mockExpenseRepository = MockIExpenseRepository();
    mockCategoryReader = MockICategoryReader();
    mockCategoryBudgetManager = MockICategoryBudgetManager();
    mockDatabase = MockIDatabase();

    service = ExpenseService(
      mockExpenseRepository,
      mockCategoryReader,
      mockCategoryBudgetManager,
      mockDatabase,
    );

    // Mock transaction to execute the callback immediately
    when(mockDatabase.transaction<dynamic>(any)).thenAnswer((invocation) async {
      final action =
          invocation.positionalArguments[0] as Future<dynamic> Function();
      return await action();
    });
  });

  group('ExpenseService', () {
    test('createExpense inserts expense and updates category budget', () async {
      final expense = ExpensesCompanion(
        amount: Value(100.0),
        description: Value('Test Expense'),
        categoryId: Value(1),
      );
      final category = Category(
        id: 1,
        name: 'Test Category',
        iconCodePoint: '123',
        color: 0xFF000000,
        budget: 1000.0,
        spent: 0.0,
        version: 1,
        createdAt: DateTime.now(),
        isSynced: false,
      );

      when(mockExpenseRepository.insertExpense(expense))
          .thenAnswer((_) async => 1);
      when(mockCategoryReader.getCategoryById(1))
          .thenAnswer((_) async => category);
      when(mockCategoryBudgetManager.updateCategorySpent(1, 100.0, 1))
          .thenAnswer((_) async => 1);

      final result = await service.createExpense(expense);

      verify(mockExpenseRepository.insertExpense(expense)).called(1);
      verify(mockCategoryBudgetManager.updateCategorySpent(1, 100.0, 1))
          .called(1);
      expect(result, 1);
    });

    test(
        'updateExpense updates expense and adjusts budgets when category changes',
        () async {
      final oldExpense = Expense(
        id: 1,
        amount: 100.0,
        description: 'Old Expense',
        date: DateTime.now(),
        categoryId: 1,
        createdAt: DateTime.now(),
        isReimbursable: false,
        version: 1,
        isSynced: false,
      );
      final newExpense = oldExpense.copyWith(
        categoryId: 2,
        amount: 150.0,
      );

      final oldCategory = Category(
        id: 1,
        name: 'Old Category',
        iconCodePoint: '123',
        color: 0xFF000000,
        budget: 1000.0,
        spent: 100.0,
        version: 1,
        createdAt: DateTime.now(),
        isSynced: false,
      );
      final newCategory = Category(
        id: 2,
        name: 'New Category',
        iconCodePoint: '456',
        color: 0xFFFFFFFF,
        budget: 2000.0,
        spent: 0.0,
        version: 1,
        createdAt: DateTime.now(),
        isSynced: false,
      );

      when(mockExpenseRepository.updateExpense(newExpense))
          .thenAnswer((_) async => true);
      when(mockCategoryReader.getCategoryById(1))
          .thenAnswer((_) async => oldCategory);
      when(mockCategoryReader.getCategoryById(2))
          .thenAnswer((_) async => newCategory);
      when(mockCategoryBudgetManager.updateCategorySpent(any, any, any))
          .thenAnswer((_) async => 1);

      await service.updateExpense(oldExpense, newExpense);

      verify(mockExpenseRepository.updateExpense(newExpense)).called(1);
      // Verify subtraction from old category (100 - 100 = 0)
      verify(mockCategoryBudgetManager.updateCategorySpent(1, 0.0, 1))
          .called(1);
      // Verify addition to new category (0 + 150 = 150)
      verify(mockCategoryBudgetManager.updateCategorySpent(2, 150.0, 1))
          .called(1);
    });

    test('deleteExpense deletes expense and restores budget', () async {
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
      final category = Category(
        id: 1,
        name: 'Test Category',
        iconCodePoint: '123',
        color: 0xFF000000,
        budget: 1000.0,
        spent: 100.0,
        version: 1,
        createdAt: DateTime.now(),
        isSynced: false,
      );

      when(mockExpenseRepository.deleteExpense(1)).thenAnswer((_) async => 1);
      when(mockCategoryReader.getCategoryById(1))
          .thenAnswer((_) async => category);
      when(mockCategoryBudgetManager.updateCategorySpent(1, 0.0, 1))
          .thenAnswer((_) async => 1);

      await service.deleteExpense(expense);

      verify(mockExpenseRepository.deleteExpense(1)).called(1);
      verify(mockCategoryBudgetManager.updateCategorySpent(1, 0.0, 1))
          .called(1);
    });
  });
}
