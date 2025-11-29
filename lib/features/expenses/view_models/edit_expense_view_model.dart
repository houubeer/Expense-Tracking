import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/features/expenses/services/i_expense_service.dart';
import 'package:expense_tracking_desktop_app/features/expenses/providers/add_expense_provider.dart';
import 'package:expense_tracking_desktop_app/providers/app_providers.dart';

/// Edit Expense State - holds form state and submission status
class EditExpenseState {
  final SubmissionStatus status;
  final String? errorMessage;
  final String? successMessage;
  final TextEditingController amountController;
  final TextEditingController descriptionController;
  final DateTime selectedDate;
  final int? selectedCategoryId;
  final Expense originalExpense;

  EditExpenseState({
    required this.status,
    this.errorMessage,
    this.successMessage,
    required this.amountController,
    required this.descriptionController,
    required this.selectedDate,
    required this.selectedCategoryId,
    required this.originalExpense,
  });

  factory EditExpenseState.fromExpense(Expense expense) {
    return EditExpenseState(
      status: SubmissionStatus.idle,
      amountController: TextEditingController(text: expense.amount.toString()),
      descriptionController: TextEditingController(text: expense.description),
      selectedDate: expense.date,
      selectedCategoryId: expense.categoryId,
      originalExpense: expense,
    );
  }

  EditExpenseState copyWith({
    SubmissionStatus? status,
    String? errorMessage,
    String? successMessage,
    DateTime? selectedDate,
    int? selectedCategoryId,
  }) {
    return EditExpenseState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      successMessage: successMessage,
      amountController: amountController,
      descriptionController: descriptionController,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      originalExpense: originalExpense,
    );
  }

  bool get isSubmitting => status == SubmissionStatus.submitting;
  bool get isSuccess => status == SubmissionStatus.success;
  bool get isError => status == SubmissionStatus.error;
  bool get isIdle => status == SubmissionStatus.idle;
}

/// Edit Expense ViewModel
class EditExpenseViewModel extends StateNotifier<EditExpenseState> {
  final IExpenseService _expenseService;

  EditExpenseViewModel(this._expenseService, Expense expense)
      : super(EditExpenseState.fromExpense(expense));

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
    state = state.copyWith(selectedCategoryId: categoryId);
  }

  /// Update expense
  Future<void> updateExpense() async {
    if (state.amountController.text.isEmpty) return;
    if (state.selectedCategoryId == null) return;

    state = state.copyWith(status: SubmissionStatus.submitting);

    try {
      final amount = double.parse(state.amountController.text);
      final description = state.descriptionController.text;

      final updatedExpense = state.originalExpense.copyWith(
        amount: amount,
        description: description,
        date: state.selectedDate,
        categoryId: state.selectedCategoryId!,
      );

      await _expenseService.updateExpense(
          state.originalExpense, updatedExpense);

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
}

/// Edit Expense ViewModel Provider
final editExpenseViewModelProvider = StateNotifierProvider.autoDispose
    .family<EditExpenseViewModel, EditExpenseState, Expense>(
  (ref, expense) {
    final expenseService = ref.watch(expenseServiceProvider);
    return EditExpenseViewModel(expenseService, expense);
  },
);
