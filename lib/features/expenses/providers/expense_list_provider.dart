import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracking_desktop_app/features/expenses/services/i_expense_service.dart';
import 'package:expense_tracking_desktop_app/providers/app_providers.dart';
import 'package:expense_tracking_desktop_app/features/expenses/view_models/expense_list_view_model.dart';

/// Expense List State - holds all filter state and computed data
class ExpenseListState {
  final String searchQuery;
  final int? selectedCategoryId;
  final DateTime? selectedDate;
  final List<ExpenseWithCategory> allExpenses;
  final List<ExpenseWithCategory> filteredExpenses;

  const ExpenseListState({
    required this.searchQuery,
    required this.selectedCategoryId,
    required this.selectedDate,
    required this.allExpenses,
    required this.filteredExpenses,
  });

  factory ExpenseListState.initial() {
    return const ExpenseListState(
      searchQuery: '',
      selectedCategoryId: null,
      selectedDate: null,
      allExpenses: [],
      filteredExpenses: [],
    );
  }

  /// Apply all filters to expenses (logic in state, not UI)
  factory ExpenseListState.withFilters({
    required String searchQuery,
    required int? selectedCategoryId,
    required DateTime? selectedDate,
    required List<ExpenseWithCategory> allExpenses,
  }) {
    final filtered = allExpenses.where((item) {
      // Search filter (description or category name)
      final matchesSearch = searchQuery.isEmpty ||
          item.expense.description
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          item.category.name.toLowerCase().contains(searchQuery.toLowerCase());

      // Category filter
      final matchesCategory =
          selectedCategoryId == null || item.category.id == selectedCategoryId;

      // Date filter (exact day match)
      final matchesDate = selectedDate == null ||
          (item.expense.date.year == selectedDate.year &&
              item.expense.date.month == selectedDate.month &&
              item.expense.date.day == selectedDate.day);

      return matchesSearch && matchesCategory && matchesDate;
    }).toList();

    return ExpenseListState(
      searchQuery: searchQuery,
      selectedCategoryId: selectedCategoryId,
      selectedDate: selectedDate,
      allExpenses: allExpenses,
      filteredExpenses: filtered,
    );
  }

  bool get hasActiveFilters =>
      searchQuery.isNotEmpty ||
      selectedCategoryId != null ||
      selectedDate != null;

  bool get isEmpty => filteredExpenses.isEmpty;
}

/// ViewModel Provider - manages state and business logic
final expenseListViewModelProvider =
    StateNotifierProvider.autoDispose<ExpenseListViewModel, ExpenseListState>(
  (ref) {
    final expenseService = ref.watch(expenseServiceProvider);
    return ExpenseListViewModel(expenseService);
  },
);
