import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/features/budget/repositories/i_category_reader.dart';
import 'package:expense_tracking_desktop_app/features/budget/repositories/i_category_writer.dart';
import 'package:expense_tracking_desktop_app/features/budget/view_models/budget_view_model.dart';
import 'package:expense_tracking_desktop_app/services/error_reporting_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'budget_view_model_test.mocks.dart';

@GenerateMocks([ICategoryReader, ICategoryWriter, ErrorReportingService])
void main() {
  late MockICategoryReader mockCategoryReader;
  late MockICategoryWriter mockCategoryWriter;
  late MockErrorReportingService mockErrorReporting;
  late BudgetViewModel viewModel;

  setUp(() {
    mockCategoryReader = MockICategoryReader();
    mockCategoryWriter = MockICategoryWriter();
    mockErrorReporting = MockErrorReportingService();

    viewModel = BudgetViewModel(
      mockCategoryReader,
      mockCategoryWriter,
      mockErrorReporting,
    );
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('BudgetViewModel', () {
    test('watchCategories streams from repository', () {
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

      when(mockCategoryReader.watchAllCategories())
          .thenAnswer((_) => Stream.value(categories));

      expect(viewModel.watchCategories(), emits(categories));
    });

    test('addCategory inserts category with correct data', () async {
      when(mockCategoryWriter.insertCategory(any)).thenAnswer((_) async => 1);

      await viewModel.addCategory(
        name: 'Test Category',
        budget: 500.0,
        color: 0xFF123456,
        iconCodePoint: '456',
      );

      final captured = verify(mockCategoryWriter.insertCategory(captureAny))
          .captured
          .single as CategoriesCompanion;

      expect(captured.name.value, 'Test Category');
      expect(captured.budget.value, 500.0);
      expect(captured.color.value, 0xFF123456);
      expect(captured.iconCodePoint.value, '456');
    });

    test('addCategory reports error on failure', () async {
      final error = Exception('Database error');
      when(mockCategoryWriter.insertCategory(any)).thenThrow(error);
      when(mockErrorReporting.reportUIError(any, any, any,
              stackTrace: anyNamed('stackTrace'), context: anyNamed('context')))
          .thenAnswer((_) async {});

      expect(
        () => viewModel.addCategory(
          name: 'Test',
          budget: 100.0,
          color: 0xFF000000,
          iconCodePoint: '123',
        ),
        throwsA(isA<Exception>()),
      );

      verify(mockErrorReporting.reportUIError(any, any, any,
              stackTrace: anyNamed('stackTrace'), context: anyNamed('context')))
          .called(1);
    });

    test('deleteCategory removes category', () async {
      when(mockCategoryWriter.deleteCategory(1)).thenAnswer((_) async => 1);

      await viewModel.deleteCategory(1);

      verify(mockCategoryWriter.deleteCategory(1)).called(1);
    });

    test('deleteCategory reports error on failure', () async {
      final error = Exception('Delete failed');
      when(mockCategoryWriter.deleteCategory(1)).thenThrow(error);
      when(mockErrorReporting.reportUIError(any, any, any,
              stackTrace: anyNamed('stackTrace'), context: anyNamed('context')))
          .thenAnswer((_) async {});

      expect(() => viewModel.deleteCategory(1), throwsA(isA<Exception>()));

      verify(mockErrorReporting.reportUIError(any, any, any,
              stackTrace: anyNamed('stackTrace'), context: anyNamed('context')))
          .called(1);
    });

    test('watchFilteredCategories filters by search query', () async {
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
          spent: 100.0,
          version: 1,
          createdAt: DateTime.now(),
        ),
      ];

      when(mockCategoryReader.watchAllCategories())
          .thenAnswer((_) => Stream.value(categories));

      final filter = BudgetFilter(searchQuery: 'food');
      final stream = viewModel.watchFilteredCategories(filter);

      await expectLater(
        stream,
        emits(predicate<List<Category>>((list) {
          return list.length == 1 && list.first.name == 'Food';
        })),
      );
    });

    test('watchFilteredCategories filters by status', () async {
      final categories = [
        Category(
          id: 1,
          name: 'Food',
          iconCodePoint: '123',
          color: 0xFF000000,
          budget: 1000.0,
          spent: 1100.0, // Over budget
          version: 1,
          createdAt: DateTime.now(),
        ),
        Category(
          id: 2,
          name: 'Transport',
          iconCodePoint: '456',
          color: 0xFFFFFFFF,
          budget: 500.0,
          spent: 100.0, // Under budget
          version: 1,
          createdAt: DateTime.now(),
        ),
      ];

      when(mockCategoryReader.watchAllCategories())
          .thenAnswer((_) => Stream.value(categories));

      final filter = BudgetFilter(statusFilter: 'Over Budget');
      final stream = viewModel.watchFilteredCategories(filter);

      await expectLater(
        stream,
        emits(predicate<List<Category>>((list) {
          return list.length == 1 && list.first.name == 'Food';
        })),
      );
    });

    test('watchFilteredCategories sorts by name', () async {
      final categories = [
        Category(
          id: 1,
          name: 'Transport',
          iconCodePoint: '123',
          color: 0xFF000000,
          budget: 1000.0,
          spent: 500.0,
          version: 1,
          createdAt: DateTime.now(),
        ),
        Category(
          id: 2,
          name: 'Food',
          iconCodePoint: '456',
          color: 0xFFFFFFFF,
          budget: 500.0,
          spent: 100.0,
          version: 1,
          createdAt: DateTime.now(),
        ),
      ];

      when(mockCategoryReader.watchAllCategories())
          .thenAnswer((_) => Stream.value(categories));

      final filter = BudgetFilter(sortBy: 'Name');
      final stream = viewModel.watchFilteredCategories(filter);

      await expectLater(
        stream,
        emits(predicate<List<Category>>((list) {
          return list.length == 2 && list.first.name == 'Food';
        })),
      );
    });

    test('getController creates and caches controller', () {
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

      final controller1 = viewModel.getController(category);
      final controller2 = viewModel.getController(category);

      expect(controller1, same(controller2));
      expect(controller1.text, '1000.00');
    });
  });
}
