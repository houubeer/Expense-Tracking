import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/database/daos/category_dao.dart';
import 'package:expense_tracking_desktop_app/features/budget/repositories/budget_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'budget_repository_test.mocks.dart';

@GenerateMocks([AppDatabase, CategoryDao])
void main() {
  late MockAppDatabase mockDatabase;
  late MockCategoryDao mockCategoryDao;
  late BudgetRepository repository;

  setUp(() {
    mockDatabase = MockAppDatabase();
    mockCategoryDao = MockCategoryDao();

    when(mockDatabase.categoryDao).thenReturn(mockCategoryDao);

    repository = BudgetRepository(mockDatabase);
  });

  group('BudgetRepository', () {
    test('getTotalBudget returns sum of category budgets', () async {
      when(mockCategoryDao.getTotalBudget()).thenAnswer((_) async => 10000.0);

      final result = await repository.getTotalBudget();

      verify(mockCategoryDao.getTotalBudget()).called(1);
      expect(result, 10000.0);
    });

    test('getTotalSpent returns sum of category expenses', () async {
      when(mockCategoryDao.getTotalSpent()).thenAnswer((_) async => 5000.0);

      final result = await repository.getTotalSpent();

      verify(mockCategoryDao.getTotalSpent()).called(1);
      expect(result, 5000.0);
    });

    test('getActiveCategories returns all categories', () async {
      final categories = [
        Category(
          id: 1,
          name: 'Food',
          iconCodePoint: '123',
          color: 0xFF000000,
          budget: 1000.0,
          spent: 500.0,
          version: 1,
          createdAt: DateTime.now(),
        ),
        Category(
          id: 2,
          name: 'Transport',
          iconCodePoint: '456',
          color: 0xFFFFFFFF,
          budget: 500.0,
          spent: 200.0,
          version: 1,
          createdAt: DateTime.now(),
        ),
      ];

      when(mockCategoryDao.getAllCategories())
          .thenAnswer((_) async => categories);

      final result = await repository.getActiveCategories();

      verify(mockCategoryDao.getAllCategories()).called(1);
      expect(result, categories);
      expect(result.length, 2);
    });

    test('watchBudgetStats streams total budget and spent', () async {
      when(mockCategoryDao.getTotalBudget()).thenAnswer((_) async => 10000.0);
      when(mockCategoryDao.getTotalSpent()).thenAnswer((_) async => 6000.0);

      final stats = await repository.getBudgetStats();

      expect(stats.totalBudget, 10000.0);
      expect(stats.totalSpent, 6000.0);
      expect(stats.remaining, 4000.0);
      expect(stats.percentageUsed, 60.0);
    });

    test('getBudgetStats calculates percentage correctly', () async {
      when(mockCategoryDao.getTotalBudget()).thenAnswer((_) async => 1000.0);
      when(mockCategoryDao.getTotalSpent()).thenAnswer((_) async => 750.0);

      final stats = await repository.getBudgetStats();

      expect(stats.percentageUsed, 75.0);
    });

    test('getBudgetStats handles zero budget', () async {
      when(mockCategoryDao.getTotalBudget()).thenAnswer((_) async => 0.0);
      when(mockCategoryDao.getTotalSpent()).thenAnswer((_) async => 100.0);

      final stats = await repository.getBudgetStats();

      expect(stats.totalBudget, 0.0);
      expect(stats.totalSpent, 100.0);
      expect(stats.percentageUsed, 0.0);
    });
  });
}
