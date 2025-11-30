import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracking_desktop_app/database/daos/expense_dao.dart';
import 'package:expense_tracking_desktop_app/providers/app_providers.dart';

/// Filter State
class ExpenseFilters {
  final String searchQuery;
  final int? selectedCategoryId;
  final DateTime? selectedDate;

  const ExpenseFilters({
    this.searchQuery = '',
    this.selectedCategoryId,
    this.selectedDate,
  });

  ExpenseFilters copyWith({
    String? searchQuery,
    int? selectedCategoryId,
    DateTime? selectedDate,
  }) {
    return ExpenseFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

/// Provider for the current filters
final expenseFiltersProvider = StateNotifierProvider<ExpenseFiltersNotifier, ExpenseFilters>((ref) {
  return ExpenseFiltersNotifier();
});

class ExpenseFiltersNotifier extends StateNotifier<ExpenseFilters> {
  ExpenseFiltersNotifier() : super(const ExpenseFilters());

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setCategoryFilter(int? categoryId) {
    state = state.copyWith(selectedCategoryId: categoryId);
  }

  void setDateFilter(DateTime? date) {
    state = state.copyWith(selectedDate: date);
  }
}

/// Provider for the filtered expenses list (Stream)
final filteredExpensesProvider = StreamProvider.autoDispose<List<ExpenseWithCategory>>((ref) {
  final filters = ref.watch(expenseFiltersProvider);
  final database = ref.watch(databaseProvider);
  
  return database.expenseDao.watchExpensesWithCategory(
    searchQuery: filters.searchQuery,
    categoryId: filters.selectedCategoryId,
    date: filters.selectedDate,
  );
});

// Legacy provider adapter to keep UI working with minimal changes if possible, 
// OR we update the UI to use the new providers.
// The UI uses `expenseListViewModelProvider` which returns `ExpenseListState`.
// Let's recreate that structure but powered by the new providers.

class ExpenseListState {
  final String searchQuery;
  final int? selectedCategoryId;
  final DateTime? selectedDate;
  final List<ExpenseWithCategory> filteredExpenses;
  final bool isLoading;
  final String? error;

  const ExpenseListState({
    required this.searchQuery,
    required this.selectedCategoryId,
    required this.selectedDate,
    required this.filteredExpenses,
    this.isLoading = false,
    this.error,
  });
}

final expenseListViewModelProvider = StateNotifierProvider.autoDispose<ExpenseListViewModel, ExpenseListState>((ref) {
  final filters = ref.watch(expenseFiltersProvider);
  final expensesAsync = ref.watch(filteredExpensesProvider);
  final filtersNotifier = ref.read(expenseFiltersProvider.notifier);
  
  return ExpenseListViewModel(filters, expensesAsync, filtersNotifier);
});

class ExpenseListViewModel extends StateNotifier<ExpenseListState> {
  final ExpenseFiltersNotifier _filtersNotifier;

  ExpenseListViewModel(
    ExpenseFilters filters,
    AsyncValue<List<ExpenseWithCategory>> expensesAsync,
    this._filtersNotifier,
  ) : super(ExpenseListState(
          searchQuery: filters.searchQuery,
          selectedCategoryId: filters.selectedCategoryId,
          selectedDate: filters.selectedDate,
          filteredExpenses: expensesAsync.value ?? [],
          isLoading: expensesAsync.isLoading,
          error: expensesAsync.hasError ? expensesAsync.error.toString() : null,
        ));

  void setSearchQuery(String query) {
    _filtersNotifier.setSearchQuery(query);
  }

  void setCategoryFilter(int? categoryId) {
    _filtersNotifier.setCategoryFilter(categoryId);
  }

  void setDateFilter(DateTime? date) {
    _filtersNotifier.setDateFilter(date);
  }
}
