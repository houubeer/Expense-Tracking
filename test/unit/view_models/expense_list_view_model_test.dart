import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/features/expenses/providers/expense_list_provider.dart';
import 'package:expense_tracking_desktop_app/features/expenses/repositories/i_expense_repository.dart';
import 'package:expense_tracking_desktop_app/features/expenses/services/i_expense_service.dart';
import 'package:expense_tracking_desktop_app/services/error_reporting_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'expense_list_view_model_test.mocks.dart';

@GenerateMocks([IExpenseRepository, IExpenseService, ErrorReportingService])
void main() {
  late MockIExpenseRepository mockRepository;
  late MockIExpenseService mockService;
  late MockErrorReportingService mockErrorReporting;
  late ExpenseListViewModel viewModel;

  setUp(() {
    mockRepository = MockIExpenseRepository();
    mockService = MockIExpenseService();
    mockErrorReporting = MockErrorReportingService();

    viewModel = ExpenseListViewModel(
      mockRepository,
      mockService,
      mockErrorReporting,
    );
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('ExpenseListViewModel', () {
    test('initial state is correct', () {
      expect(viewModel.state.filters.searchQuery, isEmpty);
      expect(viewModel.state.filters.categoryId, isNull);
      expect(viewModel.state.filters.startDate, isNull);
      expect(viewModel.state.filters.endDate, isNull);
      expect(viewModel.state.deletingExpenseId, isNull);
      expect(viewModel.state.errorMessage, isNull);
    });

    test('updateSearchQuery updates filter', () {
      viewModel.updateSearchQuery('food');

      expect(viewModel.state.filters.searchQuery, 'food');
    });

    test('updateCategoryFilter updates filter', () {
      viewModel.updateCategoryFilter(5);

      expect(viewModel.state.filters.categoryId, 5);
    });

    test('updateCategoryFilter clears when null', () {
      viewModel.updateCategoryFilter(5);
      viewModel.updateCategoryFilter(null);

      expect(viewModel.state.filters.categoryId, isNull);
    });

    test('updateDateFilter updates start and end dates', () {
      final start = DateTime(2023, 1, 1);
      final end = DateTime(2023, 12, 31);

      viewModel.updateDateFilter(start, end);

      expect(viewModel.state.filters.startDate, start);
      expect(viewModel.state.filters.endDate, end);
    });

    test('clearFilters resets all filters', () {
      viewModel.updateSearchQuery('test');
      viewModel.updateCategoryFilter(5);
      viewModel.updateDateFilter(DateTime.now(), DateTime.now());

      viewModel.clearFilters();

      expect(viewModel.state.filters.searchQuery, isEmpty);
      expect(viewModel.state.filters.categoryId, isNull);
      expect(viewModel.state.filters.startDate, isNull);
      expect(viewModel.state.filters.endDate, isNull);
    });

    test('watchFilteredExpenses returns stream from repository', () {
      final expenses = [
        ExpenseWithCategory(
          expense: Expense(
            id: 1,
            amount: 100.0,
            description: 'Test',
            date: DateTime.now(),
            categoryId: 1,
            createdAt: DateTime.now(),
          ),
          category: Category(
            id: 1,
            name: 'Food',
            iconCodePoint: '123',
            color: 0xFF000000,
            budget: 1000.0,
            spent: 100.0,
            version: 1,
            createdAt: DateTime.now(),
          ),
        ),
      ];

      when(mockRepository.watchExpensesWithCategory())
          .thenAnswer((_) => Stream.value(expenses));

      expect(viewModel.watchFilteredExpenses(),
          emits(isA<List<ExpenseWithCategory>>()));
    });

    test('deleteExpense removes expense successfully', () async {
      final expense = Expense(
        id: 1,
        amount: 100.0,
        description: 'Test',
        date: DateTime.now(),
        categoryId: 1,
        createdAt: DateTime.now(),
      );

      when(mockService.deleteExpense(expense)).thenAnswer((_) async {});

      await viewModel.deleteExpense(expense);

      verify(mockService.deleteExpense(expense)).called(1);
      expect(viewModel.state.deletingExpenseId, isNull);
    });

    test('deleteExpense sets deleting state during operation', () async {
      final expense = Expense(
        id: 1,
        amount: 100.0,
        description: 'Test',
        date: DateTime.now(),
        categoryId: 1,
        createdAt: DateTime.now(),
      );

      when(mockService.deleteExpense(expense)).thenAnswer((_) async {
        // Verify state is set during deletion
        expect(viewModel.state.deletingExpenseId, 1);
      });

      await viewModel.deleteExpense(expense);
    });

    test('deleteExpense handles errors', () async {
      final expense = Expense(
        id: 1,
        amount: 100.0,
        description: 'Test',
        date: DateTime.now(),
        categoryId: 1,
        createdAt: DateTime.now(),
      );

      final error = Exception('Delete failed');
      when(mockService.deleteExpense(expense)).thenThrow(error);
      when(mockErrorReporting.reportUIError(any, any, any,
              stackTrace: anyNamed('stackTrace'), context: anyNamed('context')))
          .thenAnswer((_) async {});

      await viewModel.deleteExpense(expense);

      expect(
          viewModel.state.errorMessage, contains('Failed to delete expense'));
      verify(mockErrorReporting.reportUIError(any, any, any,
              stackTrace: anyNamed('stackTrace'), context: anyNamed('context')))
          .called(1);
    });

    test('filters are applied correctly', () {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final tomorrow = now.add(const Duration(days: 1));

      final expenses = [
        ExpenseWithCategory(
          expense: Expense(
            id: 1,
            amount: 100.0,
            description: 'Food expense',
            date: now,
            categoryId: 1,
            createdAt: now,
          ),
          category: Category(
            id: 1,
            name: 'Food',
            iconCodePoint: '123',
            color: 0xFF000000,
            budget: 1000.0,
            spent: 100.0,
            version: 1,
            createdAt: now,
          ),
        ),
        ExpenseWithCategory(
          expense: Expense(
            id: 2,
            amount: 50.0,
            description: 'Transport expense',
            date: yesterday,
            categoryId: 2,
            createdAt: yesterday,
          ),
          category: Category(
            id: 2,
            name: 'Transport',
            iconCodePoint: '456',
            color: 0xFFFFFFFF,
            budget: 500.0,
            spent: 50.0,
            version: 1,
            createdAt: yesterday,
          ),
        ),
      ];

      when(mockRepository.watchExpensesWithCategory())
          .thenAnswer((_) => Stream.value(expenses));

      // Test search filter
      viewModel.updateSearchQuery('food');
      expect(
        viewModel.watchFilteredExpenses(),
        emits(predicate<List<ExpenseWithCategory>>(
          (list) =>
              list.length == 1 &&
              list.first.expense.description.contains('Food'),
        )),
      );

      // Test category filter
      viewModel.clearFilters();
      viewModel.updateCategoryFilter(2);
      expect(
        viewModel.watchFilteredExpenses(),
        emits(predicate<List<ExpenseWithCategory>>(
          (list) => list.length == 1 && list.first.category.name == 'Transport',
        )),
      );
    });
  });
}
