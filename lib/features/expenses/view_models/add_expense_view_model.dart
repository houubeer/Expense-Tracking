import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/features/expenses/services/expense_service.dart';
import 'package:expense_tracking_desktop_app/features/expenses/providers/add_expense_provider.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';

class AddExpenseViewModel extends StateNotifier<AddExpenseState> {
  final ExpenseService _expenseService;

  AddExpenseViewModel(this._expenseService)
      : super(AddExpenseState.initial());

  /// Submit expense to database
  Future<void> submitExpense({
    required double amount,
    required String description,
    required DateTime date,
    required int categoryId,
  }) async {
    // Set submitting status
    state = state.copyWith(status: SubmissionStatus.submitting);

    try {
      final expense = ExpensesCompanion(
        amount: drift.Value(amount),
        description: drift.Value(description),
        date: drift.Value(date),
        categoryId: drift.Value(categoryId),
      );

      await _expenseService.createExpense(expense);

      // Set success status
      state = state.copyWith(
        status: SubmissionStatus.success,
        successMessage: AppStrings.msgExpenseAdded,
      );
    } catch (e) {
      // Set error status
      state = state.copyWith(
        status: SubmissionStatus.error,
        errorMessage: 'Failed to add expense: ${e.toString()}',
      );
    }
  }

  /// Update existing expense
  Future<void> updateExpense({
    required int expenseId,
    required double amount,
    required String description,
    required DateTime date,
    required int categoryId,
  }) async {
    state = state.copyWith(status: SubmissionStatus.submitting);

    try {
      final expense = Expense(
        id: expenseId,
        amount: amount,
        description: description,
        date: date,
        categoryId: categoryId,
        createdAt: DateTime.now(), // Will be preserved by update
      );

      await _expenseService.updateExpense(expense);

      state = state.copyWith(
        status: SubmissionStatus.success,
        successMessage: 'Expense updated successfully',
      );
    } catch (e) {
      state = state.copyWith(
        status: SubmissionStatus.error,
        errorMessage: 'Failed to update expense: ${e.toString()}',
      );
    }
  }

  /// Reset form state to idle
  void resetState() {
    state = AddExpenseState.initial();
  }

  /// Validate form data (returns error message or null)
  String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an amount';
    }
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Please enter a valid number';
    }
    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }
    return null;
  }

  String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a description';
    }
    if (value.length < 3) {
      return 'Description must be at least 3 characters';
    }
    return null;
  }

  String? validateCategory(int? categoryId) {
    if (categoryId == null) {
      return 'Please select a category';
    }
    return null;
  }
}
