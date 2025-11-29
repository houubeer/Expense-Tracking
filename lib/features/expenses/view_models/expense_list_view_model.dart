import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/features/expenses/services/i_expense_service.dart';
import 'package:expense_tracking_desktop_app/features/expenses/providers/expense_list_provider.dart';

class ExpenseListViewModel extends StateNotifier<ExpenseListState> {
  final IExpenseService _expenseService;

  ExpenseListViewModel(this._expenseService)
      : super(ExpenseListState.initial()) {
    _init();
  }

  void _init() {
    // Watch expenses and automatically apply filters
    _expenseService.watchExpensesWithCategory().listen((expenses) {
      if (mounted) {
        state = ExpenseListState.withFilters(
          searchQuery: state.searchQuery,
          selectedCategoryId: state.selectedCategoryId,
          selectedDate: state.selectedDate,
          allExpenses: expenses,
        );
      }
    });
  }

  /// Set search query and reapply filters
  void setSearchQuery(String query) {
    state = ExpenseListState.withFilters(
      searchQuery: query,
      selectedCategoryId: state.selectedCategoryId,
      selectedDate: state.selectedDate,
      allExpenses: state.allExpenses,
    );
  }

  /// Set category filter and reapply filters
  void setCategoryFilter(int? categoryId) {
    state = ExpenseListState.withFilters(
      searchQuery: state.searchQuery,
      selectedCategoryId: categoryId,
      selectedDate: state.selectedDate,
      allExpenses: state.allExpenses,
    );
  }

  /// Set date filter and reapply filters
  void setDateFilter(DateTime? date) {
    state = ExpenseListState.withFilters(
      searchQuery: state.searchQuery,
      selectedCategoryId: state.selectedCategoryId,
      selectedDate: date,
      allExpenses: state.allExpenses,
    );
  }

  /// Clear all filters
  void clearFilters() {
    state = ExpenseListState.withFilters(
      searchQuery: '',
      selectedCategoryId: null,
      selectedDate: null,
      allExpenses: state.allExpenses,
    );
  }

  /// Delete expense with undo support
  Future<void> deleteExpense(Expense expense) async {
    await _expenseService.deleteExpense(expense);
  }
}
