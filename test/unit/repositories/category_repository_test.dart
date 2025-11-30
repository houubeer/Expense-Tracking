import 'package:drift/drift.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/database/daos/category_dao.dart';
import 'package:expense_tracking_desktop_app/features/budget/repositories/category_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'category_repository_test.mocks.dart';

@GenerateMocks([AppDatabase, CategoryDao])
void main() {
  late MockAppDatabase mockDatabase;
  late MockCategoryDao mockCategoryDao;
  late CategoryRepository repository;

  setUp(() {
    mockDatabase = MockAppDatabase();
    mockCategoryDao = MockCategoryDao();

    when(mockDatabase.categoryDao).thenReturn(mockCategoryDao);

    repository = CategoryRepository(mockDatabase);
  });

  group('CategoryRepository', () {
    test('insertCategory delegates to CategoryDao', () async {
      final category = const CategoriesCompanion(
        name: Value('Food'),
        iconCodePoint: Value('123'),
        color: Value(0xFF000000),
        budget: Value(1000.0),
      );

      when(mockCategoryDao.insertCategory(category)).thenAnswer((_) async => 1);

      final result = await repository.insertCategory(category);

      verify(mockCategoryDao.insertCategory(category)).called(1);
      expect(result, 1);
    });

    test('updateCategory delegates to CategoryDao', () async {
      final category = Category(
        id: 1,
        name: 'Food',
        iconCodePoint: '123',
        color: 0xFF000000,
        budget: 1000.0,
        spent: 500.0,
        version: 1,
        createdAt: DateTime.now(),
      );

      when(mockCategoryDao.updateCategory(category))
          .thenAnswer((_) async => true);

      await repository.updateCategory(category);

      verify(mockCategoryDao.updateCategory(category)).called(1);
    });

    test('deleteCategory delegates to CategoryDao', () async {
      when(mockCategoryDao.deleteCategory(1)).thenAnswer((_) async => 1);

      await repository.deleteCategory(1);

      verify(mockCategoryDao.deleteCategory(1)).called(1);
    });

    test('getCategoryById delegates to CategoryDao', () async {
      final category = Category(
        id: 1,
        name: 'Food',
        iconCodePoint: '123',
        color: 0xFF000000,
        budget: 1000.0,
        spent: 500.0,
        version: 1,
        createdAt: DateTime.now(),
      );

      when(mockCategoryDao.getCategoryById(1))
          .thenAnswer((_) async => category);

      final result = await repository.getCategoryById(1);

      verify(mockCategoryDao.getCategoryById(1)).called(1);
      expect(result, category);
    });

    test('getAllCategories delegates to CategoryDao', () async {
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
      ];

      when(mockCategoryDao.getAllCategories())
          .thenAnswer((_) async => categories);

      final result = await repository.getAllCategories();

      verify(mockCategoryDao.getAllCategories()).called(1);
      expect(result, categories);
    });

    test('watchAllCategories delegates to CategoryDao', () {
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
      ];

      when(mockCategoryDao.watchAllCategories())
          .thenAnswer((_) => Stream.value(categories));

      final stream = repository.watchAllCategories();

      expect(stream, emits(categories));
    });

    test('updateCategorySpent delegates to CategoryDao', () async {
      when(mockCategoryDao.updateCategorySpent(1, 500.0, 1))
          .thenAnswer((_) async => 1);

      await repository.updateCategorySpent(1, 500.0, 1);

      verify(mockCategoryDao.updateCategorySpent(1, 500.0, 1)).called(1);
    });

    // Note: getTotalBudget and getTotalSpent are not in CategoryRepository
    // These are implemented in DashboardBudgetReader interface
  });
}
