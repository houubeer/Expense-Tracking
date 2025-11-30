import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/features/expenses/services/i_expense_service.dart';
import 'package:expense_tracking_desktop_app/features/expenses/providers/add_expense_provider.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';
import 'package:expense_tracking_desktop_app/services/logger_service.dart';
import 'package:expense_tracking_desktop_app/services/error_reporting_service.dart';

class AddExpenseViewModel extends StateNotifier<AddExpenseState> {
  final IExpenseService _expenseService;
  final ErrorReportingService _errorReporting;
  final _logger = LoggerService.instance;

  AddExpenseViewModel(
      this._expenseService, this._errorReporting, int? preSelectedCategoryId)
      : super(AddExpenseState.initial(
            preSelectedCategoryId: preSelectedCategoryId));

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
    // Validate amount
    final amountError = validateAmount(state.amountController.text);
    if (amountError != null) {
      state = state.copyWith(
        status: SubmissionStatus.error,
        errorMessage: amountError,
      );
      return;
    }

    // Validate category
    final categoryError = validateCategory(state.selectedCategoryId);
    if (categoryError != null) {
      state = state.copyWith(
        status: SubmissionStatus.error,
        errorMessage: categoryError,
      );
      return;
    }

    // Validate date
    final dateError = validateDate(state.selectedDate);
    if (dateError != null) {
      state = state.copyWith(
        status: SubmissionStatus.error,
        errorMessage: dateError,
      );
      return;
    }

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

      _logger.debug(
          'AddExpenseViewModel: Creating expense - amount=$amount, categoryId=${state.selectedCategoryId}');
      await _expenseService.createExpense(expense);
      _logger.info('AddExpenseViewModel: Expense created successfully');

      // Set success status
      state = state.copyWith(
        status: SubmissionStatus.success,
        successMessage: AppStrings.msgExpenseAdded,
      );
    } catch (e, stackTrace) {
      _logger.error('AddExpenseViewModel: Failed to create expense',
          error: e, stackTrace: stackTrace);
      await _errorReporting.reportUIError(
        'AddExpenseViewModel',
        'submitExpense',
        e,
        stackTrace: stackTrace,
        context: {
          'amount': state.amountController.text,
          'categoryId': state.selectedCategoryId?.toString() ?? 'null',
          'date': state.selectedDate.toString(),
        },
      );
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
    // Validate amount
    final amountError = validateAmount(state.amountController.text);
    if (amountError != null) {
      state = state.copyWith(
        status: SubmissionStatus.error,
        errorMessage: amountError,
      );
      return;
    }

    final descriptionError = validateDescription(state.descriptionController.text);
    if (descriptionError != null) {
      state = state.copyWith(
        status: SubmissionStatus.error,
        errorMessage: descriptionError,
      );
      return;
    }

    if (state.selectedCategoryId == null) {
      state = state.copyWith(
        status: SubmissionStatus.error,
        errorMessage: 'Please select a category',
      );
      return;
    }

    state = state.copyWith(status: SubmissionStatus.submitting);

    try {
      final amount = double.parse(state.amountController.text);
      final newExpense = oldExpense.copyWith(
        amount: amount,
        description: state.descriptionController.text,
        categoryId: state.selectedCategoryId!,
        date: state.selectedDate,
      );

      await _expenseService.updateExpense(oldExpense, newExpense);
      _logger.info('AddExpenseViewModel: Expense updated successfully');

      state = state.copyWith(
        status: SubmissionStatus.success,
        successMessage: 'Expense updated successfully',
      );
    } catch (e, stackTrace) {
      _logger.error('AddExpenseViewModel: Failed to update expense',
          error: e, stackTrace: stackTrace);
      await _errorReporting.reportUIError(
        'AddExpenseViewModel',
        'updateExpense',
        e,
        stackTrace: stackTrace,
        context: {
          'expenseId': oldExpense.id.toString(),
          'newAmount': state.amountController.text,
          'oldAmount': oldExpense.amount.toString(),
        },
      );
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

  String? validateDate(DateTime date) {
    final now = DateTime.now();
    final futureLimit = DateTime(now.year + 1, now.month, now.day);

    if (date.isAfter(futureLimit)) {
      return 'Date cannot be more than 1 year in the future';
    }

    // Allow dates up to 10 years in the past for historical data
    final pastLimit = DateTime(now.year - 10, now.month, now.day);
    if (date.isBefore(pastLimit)) {
      return 'Date cannot be more than 10 years in the past';
    }

    return null;
  }
}
