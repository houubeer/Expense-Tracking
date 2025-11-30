import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/features/budget/repositories/i_category_repository.dart';
import 'package:expense_tracking_desktop_app/features/home/providers/dashboard_provider.dart';
import 'package:expense_tracking_desktop_app/features/home/view_models/dashboard_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'dashboard_view_model_test.mocks.dart';

@GenerateMocks([ICategoryRepository])
void main() {
  late MockICategoryRepository mockCategoryRepository;
  late DashboardViewModel viewModel;

  setUp(() {
    mockCategoryRepository = MockICategoryRepository();
    viewModel = DashboardViewModel(mockCategoryRepository);
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('DashboardViewModel', () {
    test('calculateDashboardState with empty categories', () async {
      when(mockCategoryRepository.getAllCategories())
          .thenAnswer((_) async => []);

      final state = await viewModel.calculateDashboardState();

      expect(state.activeCategories, 0);
      expect(state.totalBudget, 0.0);
      expect(state.totalExpenses, 0.0);
      expect(state.totalBalance, 0.0);
      expect(state.dailyAverage, 0.0);
      expect(state.recentExpenses, isEmpty);
      expect(state.budgetData, isEmpty);
    });

    test('calculateDashboardState with categories', () async {
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

      when(mockCategoryRepository.getAllCategories())
          .thenAnswer((_) async => categories);

      final state = await viewModel.calculateDashboardState();

      expect(state.activeCategories, 2);
      expect(state.totalBudget, 1500.0);
      expect(state.totalExpenses, 700.0);
      expect(state.totalBalance, 800.0);
      expect(state.budgetData.length, 2);
    });

    test('calculateDashboardState calculates daily average correctly',
        () async {
      final categories = [
        Category(
          id: 1,
          name: 'Food',
          iconCodePoint: '123',
          color: 0xFF000000,
          budget: 3000.0, // Monthly budget
          spent: 900.0, // Spent
          version: 1,
          createdAt: DateTime.now(),
        ),
      ];

      when(mockCategoryRepository.getAllCategories())
          .thenAnswer((_) async => categories);

      final state = await viewModel.calculateDashboardState();

      // Daily average should be totalBudget / 30
      expect(state.dailyAverage, 3000.0 / 30);
    });

    test('watchDashboardState streams updates', () {
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

      when(mockCategoryRepository.watchAllCategories())
          .thenAnswer((_) => Stream.value(categories));

      expect(
        viewModel.watchDashboardState(),
        emits(isA<DashboardState>()),
      );
    });

    test('budgetData contains correct category information', () async {
      final categories = [
        Category(
          id: 1,
          name: 'Food',
          iconCodePoint: '123',
          color: 0xFF000000,
          budget: 1000.0,
          spent: 600.0,
          version: 1,
          createdAt: DateTime.now(),
        ),
      ];

      when(mockCategoryRepository.getAllCategories())
          .thenAnswer((_) async => categories);

      final state = await viewModel.calculateDashboardState();

      expect(state.budgetData.length, 1);
      expect(state.budgetData.first.categoryName, 'Food');
      expect(state.budgetData.first.budget, 1000.0);
      expect(state.budgetData.first.spent, 600.0);
      expect(state.budgetData.first.percentage, 60.0);
    });

    test('budgetData calculates percentage correctly', () async {
      final categories = [
        Category(
          id: 1,
          name: 'Food',
          iconCodePoint: '123',
          color: 0xFF000000,
          budget: 500.0,
          spent: 250.0,
          version: 1,
          createdAt: DateTime.now(),
        ),
        Category(
          id: 2,
          name: 'Transport',
          iconCodePoint: '456',
          color: 0xFFFFFFFF,
          budget: 200.0,
          spent: 200.0,
          version: 1,
          createdAt: DateTime.now(),
        ),
      ];

      when(mockCategoryRepository.getAllCategories())
          .thenAnswer((_) async => categories);

      final state = await viewModel.calculateDashboardState();

      expect(state.budgetData[0].percentage, 50.0);
      expect(state.budgetData[1].percentage, 100.0);
    });

    test('handles categories with zero budget', () async {
      final categories = [
        Category(
          id: 1,
          name: 'Food',
          iconCodePoint: '123',
          color: 0xFF000000,
          budget: 0.0,
          spent: 100.0,
          version: 1,
          createdAt: DateTime.now(),
        ),
      ];

      when(mockCategoryRepository.getAllCategories())
          .thenAnswer((_) async => categories);

      final state = await viewModel.calculateDashboardState();

      expect(state.budgetData.first.percentage, 0.0);
      expect(state.totalBudget, 0.0);
      expect(state.totalExpenses, 100.0);
    });
  });
}
