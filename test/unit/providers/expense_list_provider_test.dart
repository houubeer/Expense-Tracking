import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracking_desktop_app/features/expenses/providers/expense_list_provider.dart';
import 'package:expense_tracking_desktop_app/features/expenses/widgets/expense_filters.dart'
    show ReimbursableFilter;

void main() {
  group('ExpenseFilters State Management', () {
    group('ExpenseFilters copyWith', () {
      test('updates search query', () {
        const filters = ExpenseFilters(searchQuery: 'initial');
        final updated = filters.copyWith(searchQuery: 'updated');
        
        expect(updated.searchQuery, equals('updated'));
      });

      test('updates category filter', () {
        const filters = ExpenseFilters(selectedCategoryId: null);
        final updated = filters.copyWith(selectedCategoryId: 5);
        
        expect(updated.selectedCategoryId, equals(5));
      });

      test('clears category filter when clearCategoryId is true', () {
        const filters = ExpenseFilters(selectedCategoryId: 5);
        final updated = filters.copyWith(clearCategoryId: true);
        
        expect(updated.selectedCategoryId, isNull);
      });

      test('updates date filter', () {
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 1, 31);
        const filters = ExpenseFilters();
        final updated = filters.copyWith(startDate: startDate, endDate: endDate);
        
        expect(updated.startDate, equals(startDate));
        expect(updated.endDate, equals(endDate));
      });

      test('clears date filter', () {
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 1, 31);
        final filters = ExpenseFilters(startDate: startDate, endDate: endDate);
        final updated = filters.copyWith(clearStartDate: true, clearEndDate: true);
        
        expect(updated.startDate, isNull);
        expect(updated.endDate, isNull);
      });

      test('updates reimbursable filter', () {
        const filters = ExpenseFilters(
          reimbursableFilter: ReimbursableFilter.all,
        );
        final updated = filters.copyWith(
          reimbursableFilter: ReimbursableFilter.reimbursable,
        );
        
        expect(updated.reimbursableFilter, equals(ReimbursableFilter.reimbursable));
      });

      test('preserves other fields when updating one', () {
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 1, 31);
        final filters = ExpenseFilters(
          searchQuery: 'test',
          selectedCategoryId: 3,
          startDate: startDate,
          endDate: endDate,
          reimbursableFilter: ReimbursableFilter.nonReimbursable,
        );
        
        final updated = filters.copyWith(searchQuery: 'updated');
        
        expect(updated.searchQuery, equals('updated'));
        expect(updated.selectedCategoryId, equals(3));
        expect(updated.startDate, equals(startDate));
        expect(updated.endDate, equals(endDate));
        expect(updated.reimbursableFilter, equals(ReimbursableFilter.nonReimbursable));
      });
    });

    group('ReimbursableFilter enum', () {
      test('has all required values', () {
        expect(ReimbursableFilter.all, isNotNull);
        expect(ReimbursableFilter.reimbursable, isNotNull);
        expect(ReimbursableFilter.nonReimbursable, isNotNull);
      });

      test('can compare filter values', () {
        expect(
          ReimbursableFilter.reimbursable == ReimbursableFilter.reimbursable,
          isTrue,
        );
        expect(
          ReimbursableFilter.reimbursable == ReimbursableFilter.nonReimbursable,
          isFalse,
        );
      });
    });

    group('ExpenseFilters equality', () {
      test('equal filters are equal', () {
        const filter1 = ExpenseFilters(
          searchQuery: 'test',
          selectedCategoryId: 5,
        );
        const filter2 = ExpenseFilters(
          searchQuery: 'test',
          selectedCategoryId: 5,
        );
        
        expect(filter1 == filter2, isTrue);
      });

      test('different filters are not equal', () {
        const filter1 = ExpenseFilters(searchQuery: 'test');
        const filter2 = ExpenseFilters(searchQuery: 'different');
        
        expect(filter1 == filter2, isFalse);
      });
    });
  });

  group('ExpenseFiltersNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('setSearchQuery updates state', () {
      final notifier = container.read(expenseFiltersProvider.notifier);
      notifier.setSearchQuery('office supplies');
      
      final filters = container.read(expenseFiltersProvider);
      expect(filters.searchQuery, equals('office supplies'));
    });

    test('setCategoryFilter updates state', () {
      final notifier = container.read(expenseFiltersProvider.notifier);
      notifier.setCategoryFilter(3);
      
      final filters = container.read(expenseFiltersProvider);
      expect(filters.selectedCategoryId, equals(3));
    });

    test('setCategoryFilter with null clears filter', () {
      final notifier = container.read(expenseFiltersProvider.notifier);
      notifier.setCategoryFilter(3);
      notifier.setCategoryFilter(null);
      
      final filters = container.read(expenseFiltersProvider);
      expect(filters.selectedCategoryId, isNull);
    });

    test('setDateFilter updates state', () {
      final notifier = container.read(expenseFiltersProvider.notifier);
      final date = DateTime(2024, 1, 15);
      notifier.setDateFilter(date);
      
      final filters = container.read(expenseFiltersProvider);
      // setDateFilter sets both start and end to the same date for single-day filtering
      expect(filters.startDate, equals(date));
      expect(filters.endDate, equals(date));
    });

    test('setReimbursableFilter updates state', () {
      final notifier = container.read(expenseFiltersProvider.notifier);
      notifier.setReimbursableFilter(ReimbursableFilter.reimbursable);
      
      final filters = container.read(expenseFiltersProvider);
      expect(
        filters.reimbursableFilter,
        equals(ReimbursableFilter.reimbursable),
      );
    });

    test('multiple filters can be set independently', () {
      final notifier = container.read(expenseFiltersProvider.notifier);
      final date = DateTime(2024, 1, 15);
      
      notifier.setSearchQuery('office');
      notifier.setCategoryFilter(2);
      notifier.setDateFilter(date);
      notifier.setReimbursableFilter(ReimbursableFilter.nonReimbursable);
      
      final filters = container.read(expenseFiltersProvider);
      expect(filters.searchQuery, equals('office'));
      expect(filters.selectedCategoryId, equals(2));
      expect(filters.startDate, equals(date));
      expect(filters.endDate, equals(date));
      expect(
        filters.reimbursableFilter,
        equals(ReimbursableFilter.nonReimbursable),
      );
    });
  });
}
