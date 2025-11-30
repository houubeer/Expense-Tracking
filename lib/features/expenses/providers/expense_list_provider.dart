import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracking_desktop_app/features/expenses/services/i_expense_service.dart';
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
  final expenseService = ref.watch(expenseServiceProvider);
  
  // Use the service layer which returns the domain-level ExpenseWithCategory
  // Then apply client-side filtering
  return expenseService.watchExpensesWithCategory().map((expenses) {
    var filtered = expenses;
    
    // Apply search query filter
    if (filters.searchQuery.isNotEmpty) {
      final query = filters.searchQuery.toLowerCase();
      filtered = filtered.where((e) {
        return e.expense.description.toLowerCase().contains(query) ||
               e.category.name.toLowerCase().contains(query);
      }).toList();
    }
    
    // Apply category filter
    if (filters.selectedCategoryId != null) {
      filtered = filtered.where((e) {
        return e.expense.categoryId == filters.selectedCategoryId;
      }).toList();
    }
    
    // Apply date filter
    if (filters.selectedDate != null) {
      final filterDate = filters.selectedDate!;
      final start = DateTime(filterDate.year, filterDate.month, filterDate.day);
      final end = start.add(const Duration(days: 1));
      filtered = filtered.where((e) {
        return e.expense.date.isAfter(start.subtract(const Duration(milliseconds: 1))) &&
               e.expense.date.isBefore(end);
      }).toList();
    }
    
    return filtered;
  });
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
