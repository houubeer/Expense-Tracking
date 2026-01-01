import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracking_desktop_app/features/expenses/services/i_expense_service.dart';
import 'package:expense_tracking_desktop_app/features/expenses/widgets/expense_filters.dart'
    show ReimbursableFilter;
import 'package:expense_tracking_desktop_app/providers/app_providers.dart';

/// Filter State
class ExpenseFilters {
  final String searchQuery;
  final int? selectedCategoryId;
  final DateTime? startDate; // Changed: date range support
  final DateTime? endDate; // New: date range support
  final ReimbursableFilter reimbursableFilter;

  const ExpenseFilters({
    this.searchQuery = '',
    this.selectedCategoryId,
    this.startDate,
    this.endDate,
    this.reimbursableFilter = ReimbursableFilter.all,
  });

  ExpenseFilters copyWith({
    String? searchQuery,
    int? selectedCategoryId,
    DateTime? startDate,
    DateTime? endDate,
    ReimbursableFilter? reimbursableFilter,
    bool clearCategoryId = false,
    bool clearStartDate = false,
    bool clearEndDate = false,
  }) {
    return ExpenseFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategoryId: clearCategoryId
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      reimbursableFilter: reimbursableFilter ?? this.reimbursableFilter,
    );
  }
}

/// Provider for the current filters
final expenseFiltersProvider =
    StateNotifierProvider<ExpenseFiltersNotifier, ExpenseFilters>((ref) {
  return ExpenseFiltersNotifier();
});

class ExpenseFiltersNotifier extends StateNotifier<ExpenseFilters> {
  ExpenseFiltersNotifier() : super(const ExpenseFilters());

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setCategoryFilter(int? categoryId) {
    state = state.copyWith(
      selectedCategoryId: categoryId,
      clearCategoryId: categoryId == null,
    );
  }

  void setDateFilter(DateTime? date) {
    // Backward compatibility: single date sets both start and end to same day
    if (date != null) {
      final start = DateTime(date.year, date.month, date.day);
      final end = DateTime(date.year, date.month, date.day, 23, 59, 59);
      state = state.copyWith(startDate: start, endDate: end);
    } else {
      state = state.copyWith(clearStartDate: true, clearEndDate: true);
    }
  }

  void setDateRangeFilter(DateTime? startDate, DateTime? endDate) {
    state = state.copyWith(
      startDate: startDate,
      endDate: endDate,
      clearStartDate: startDate == null,
      clearEndDate: endDate == null,
    );
  }

  void setReimbursableFilter(ReimbursableFilter filter) {
    state = state.copyWith(reimbursableFilter: filter);
  }
}

/// Provider for the filtered expenses list (Stream)
final filteredExpensesProvider =
    StreamProvider.autoDispose<List<ExpenseWithCategory>>((ref) {
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

    // Apply date range filter
    if (filters.startDate != null || filters.endDate != null) {
      filtered = filtered.where((e) {
        final expenseDate = e.expense.date;
        final afterStart = filters.startDate == null ||
            expenseDate.isAfter(filters.startDate!.subtract(const Duration(milliseconds: 1)));
        final beforeEnd = filters.endDate == null ||
            expenseDate.isBefore(filters.endDate!.add(const Duration(days: 1)));
        return afterStart && beforeEnd;
      }).toList();
    }

    // Apply reimbursable filter
    if (filters.reimbursableFilter != ReimbursableFilter.all) {
      final isReimbursable =
          filters.reimbursableFilter == ReimbursableFilter.reimbursable;
      filtered = filtered.where((e) {
        return e.expense.isReimbursable == isReimbursable;
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
  final DateTime? selectedDate; // Deprecated: kept for backward compatibility
  final DateTime? startDate; // New: date range support
  final DateTime? endDate; // New: date range support
  final ReimbursableFilter reimbursableFilter;
  final List<ExpenseWithCategory> filteredExpenses;
  final bool isLoading;
  final String? error;

  const ExpenseListState({
    required this.searchQuery,
    required this.selectedCategoryId,
    this.selectedDate,
    this.startDate,
    this.endDate,
    required this.reimbursableFilter,
    required this.filteredExpenses,
    this.isLoading = false,
    this.error,
  });
}

final expenseListViewModelProvider =
    StateNotifierProvider.autoDispose<ExpenseListViewModel, ExpenseListState>(
        (ref) {
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
          startDate: filters.startDate,
          endDate: filters.endDate,
          reimbursableFilter: filters.reimbursableFilter,
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

  void setDateRangeFilter(DateTime? startDate, DateTime? endDate) {
    _filtersNotifier.setDateRangeFilter(startDate, endDate);
  }

  void setReimbursableFilter(ReimbursableFilter filter) {
    _filtersNotifier.setReimbursableFilter(filter);
  }
}
