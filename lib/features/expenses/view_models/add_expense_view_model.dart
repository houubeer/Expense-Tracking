import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/features/expenses/services/i_expense_service.dart';
import 'package:expense_tracking_desktop_app/features/expenses/providers/add_expense_provider.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';

class AddExpenseViewModel extends StateNotifier<AddExpenseState> {
  final IExpenseService _expenseService;

  AddExpenseViewModel(this._expenseService, int? preSelectedCategoryId)
      : super(AddExpenseState.initial(preSelectedCategoryId: preSelectedCategoryId));

  @override
  void dispose() {
    state.amountController.dispose();
    state.descriptionController.dispose();
    super.dispose();
  }

  /// Update selected date
  void updateDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  /// Update selected category
  void updateCategory(int? categoryId) {
    state = state.copyWith(
      selectedCategoryId: categoryId,
      clearCategoryId: categoryId == null,
    );
  }

  /// Reset form to initial state
  void resetForm({int? preSelectedCategoryId}) {
    state.amountController.clear();
    state.descriptionController.clear();
    state = state.copyWith(
      status: SubmissionStatus.idle,
      selectedDate: DateTime.now(),
      selectedCategoryId: preSelectedCategoryId,
      clearCategoryId: preSelectedCategoryId == null,
    );
  }

  /// Submit expense to database
  Future<void> submitExpense() async {
    // Validate controllers have data
    if (state.amountController.text.isEmpty) return;
    if (state.selectedCategoryId == null) return;
  /// Submit expense to database
  Future<void> submitExpense() async {
    // Validate controllers have data
    if (state.amountController.text.isEmpty) return;
    if (state.selectedCategoryId == null) return;

    // Set submitting status
    state = state.copyWith(status: SubmissionStatus.submitting);

    try {
      final amount = double.parse(state.amountController.text);
      final description = state.descriptionController.text;

      final expense = ExpensesCompanion(
        amount: drift.Value(amount),
        description: drift.Value(description),
        date: drift.Value(state.selectedDate),
        categoryId: drift.Value(state.selectedCategoryId!),
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
    required Expense oldExpense,
  }) async {
    if (state.amountController.text.isEmpty) return;
    if (state.selectedCategoryId == null) return;

    state = state.copyWith(status: SubmissionStatus.submitting);

    try {
      final amount = double.parse(state.amountController.text);
      final description = state.descriptionController.text;

      final newExpense = Expense(
        id: oldExpense.id,
        amount: amount,
        description: description,
        date: state.selectedDate,
        categoryId: state.selectedCategoryId!,
        createdAt: oldExpense.createdAt,
      );

      await _expenseService.updateExpense(oldExpense, newExpense);

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

  /// Reset state (deprecated - use resetForm)
  @deprecated
  void resetState() {
    resetForm();
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
