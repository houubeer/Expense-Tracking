import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/features/expenses/services/i_expense_service.dart';
import 'package:expense_tracking_desktop_app/features/expenses/providers/add_expense_provider.dart';
import 'package:expense_tracking_desktop_app/providers/app_providers.dart';
import 'package:expense_tracking_desktop_app/services/logger_service.dart';
import 'package:expense_tracking_desktop_app/services/error_reporting_service.dart';

/// Edit Expense State - holds form state and submission status
class EditExpenseState {

  EditExpenseState({
    required this.status,
    required this.amountController, required this.descriptionController, required this.selectedDate, required this.selectedCategoryId, required this.isReimbursable, required this.originalExpense, this.errorMessage,
    this.successMessage,
    this.receiptPath,
  });

  factory EditExpenseState.fromExpense(Expense expense) {
    return EditExpenseState(
      status: SubmissionStatus.idle,
      amountController: TextEditingController(text: expense.amount.toString()),
      descriptionController: TextEditingController(text: expense.description),
      selectedDate: expense.date,
      selectedCategoryId: expense.categoryId,
      isReimbursable: expense.isReimbursable,
      receiptPath: expense.receiptPath,
      originalExpense: expense,
    );
  }
  final SubmissionStatus status;
  final String? errorMessage;
  final String? successMessage;
  final TextEditingController amountController;
  final TextEditingController descriptionController;
  final DateTime selectedDate;
  final int? selectedCategoryId;
  final bool isReimbursable;
  final String? receiptPath;
  final Expense originalExpense;

  EditExpenseState copyWith({
    SubmissionStatus? status,
    String? errorMessage,
    String? successMessage,
    DateTime? selectedDate,
    int? selectedCategoryId,
    bool? isReimbursable,
    String? receiptPath,
    bool clearReceiptPath = false,
  }) {
    return EditExpenseState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      successMessage: successMessage,
      amountController: amountController,
      descriptionController: descriptionController,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      isReimbursable: isReimbursable ?? this.isReimbursable,
      receiptPath: clearReceiptPath ? null : (receiptPath ?? this.receiptPath),
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

  EditExpenseViewModel(
      this._expenseService, this._errorReporting, Expense expense,)
      : super(EditExpenseState.fromExpense(expense));
  final IExpenseService _expenseService;
  final ErrorReportingService _errorReporting;
  final _logger = LoggerService.instance;

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

  /// Update reimbursable status
  void updateReimbursable(bool isReimbursable) {
    state = state.copyWith(isReimbursable: isReimbursable);
  }

  /// Update receipt path
  void updateReceiptPath(String? path) {
    state = state.copyWith(
      receiptPath: path,
      clearReceiptPath: path == null,
    );
  }

  /// Remove receipt
  void removeReceipt() {
    state = state.copyWith(clearReceiptPath: true);
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
        categoryId: state.selectedCategoryId,
        isReimbursable: state.isReimbursable,
        receiptPath: Value(state.receiptPath),
      );

      _logger.debug(
          'EditExpenseViewModel: Updating expense - id=${state.originalExpense.id}',);
      await _expenseService.updateExpense(
          state.originalExpense, updatedExpense,);
      _logger.info(
          'EditExpenseViewModel: Expense updated successfully - id=${state.originalExpense.id}',);

      state = state.copyWith(
        status: SubmissionStatus.success,
        successMessage: 'Expense updated successfully',
      );
    } catch (e, stackTrace) {
      _logger.error(
          'EditExpenseViewModel: Failed to update expense - id=${state.originalExpense.id}',
          error: e,
          stackTrace: stackTrace,);
      await _errorReporting.reportUIError(
        'EditExpenseViewModel',
        'updateExpense',
        e,
        stackTrace: stackTrace,
        context: {
          'expenseId': state.originalExpense.id.toString(),
          'newAmount': state.amountController.text,
        },
      );
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
    final errorReporting = ref.watch(errorReportingServiceProvider);
    return EditExpenseViewModel(expenseService, errorReporting, expense);
  },
);
