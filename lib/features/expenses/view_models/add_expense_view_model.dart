import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/features/expenses/services/i_expense_service.dart';
import 'package:expense_tracking_desktop_app/features/expenses/providers/add_expense_provider.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';
import 'package:expense_tracking_desktop_app/services/logger_service.dart';
import 'package:expense_tracking_desktop_app/services/error_reporting_service.dart';
import 'package:expense_tracking_desktop_app/core/validators/expense_validators.dart';
import 'package:expense_tracking_desktop_app/core/errors/error_mapper.dart';

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

  /// Reset form to initial state
  void resetForm({int? preSelectedCategoryId}) {
    state.amountController.clear();
    state.descriptionController.clear();
    state = state.copyWith(
      status: SubmissionStatus.idle,
      selectedDate: DateTime.now(),
      selectedCategoryId: preSelectedCategoryId,
      clearCategoryId: preSelectedCategoryId == null,
      isReimbursable: false,
      clearReceiptPath: true,
    );
  }

  /// Submit expense to database
  Future<void> submitExpense() async {
    // Validate amount using centralized validator
    final amountError =
        ExpenseValidators.validateAmount(state.amountController.text);
    if (amountError != null) {
      state = state.copyWith(
        status: SubmissionStatus.error,
        errorMessage: amountError,
      );
      return;
    }

    // Validate description using centralized validator
    final descriptionError =
        ExpenseValidators.validateDescription(state.descriptionController.text);
    if (descriptionError != null) {
      state = state.copyWith(
        status: SubmissionStatus.error,
        errorMessage: descriptionError,
      );
      return;
    }

    // Validate category using centralized validator
    final categoryError =
        ExpenseValidators.validateCategory(state.selectedCategoryId);
    if (categoryError != null) {
      state = state.copyWith(
        status: SubmissionStatus.error,
        errorMessage: categoryError,
      );
      return;
    }

    // Validate date using centralized validator
    final dateError = ExpenseValidators.validateDate(state.selectedDate);
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
      final description = state.descriptionController.text.trim();

      final expense = ExpensesCompanion(
        amount: drift.Value(amount),
        description: drift.Value(description),
        date: drift.Value(state.selectedDate),
        categoryId: drift.Value(state.selectedCategoryId!),
        isReimbursable: drift.Value(state.isReimbursable),
        receiptPath: drift.Value(state.receiptPath),
      );

      _logger.info('AddExpenseViewModel: Creating expense');
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

      // Only report if it's an unexpected error
      if (ErrorMapper.shouldReportError(e)) {
        await _errorReporting.reportUIError(
          'AddExpenseViewModel',
          'submitExpense',
          e,
          stackTrace: stackTrace,
          context: {
            'errorCode': ErrorMapper.getErrorCode(e),
          },
        );
      }

      // Set user-friendly error status
      state = state.copyWith(
        status: SubmissionStatus.error,
        errorMessage: ErrorMapper.getUserFriendlyMessage(e),
      );
    }
  }

  /// Update existing expense
  Future<void> updateExpense({
    required Expense oldExpense,
  }) async {
    // Validate amount using centralized validator
    final amountError =
        ExpenseValidators.validateAmount(state.amountController.text);
    if (amountError != null) {
      state = state.copyWith(
        status: SubmissionStatus.error,
        errorMessage: amountError,
      );
      return;
    }

    // Validate description using centralized validator
    final descriptionError =
        ExpenseValidators.validateDescription(state.descriptionController.text);
    if (descriptionError != null) {
      state = state.copyWith(
        status: SubmissionStatus.error,
        errorMessage: descriptionError,
      );
      return;
    }

    // Validate category
    final categoryError =
        ExpenseValidators.validateCategory(state.selectedCategoryId);
    if (categoryError != null) {
      state = state.copyWith(
        status: SubmissionStatus.error,
        errorMessage: categoryError,
      );
      return;
    }

    // Validate date
    final dateError = ExpenseValidators.validateDate(state.selectedDate);
    if (dateError != null) {
      state = state.copyWith(
        status: SubmissionStatus.error,
        errorMessage: dateError,
      );
      return;
    }

    state = state.copyWith(status: SubmissionStatus.submitting);

    try {
      final amount = double.parse(state.amountController.text);
      final newExpense = oldExpense.copyWith(
        amount: amount,
        description: state.descriptionController.text.trim(),
        categoryId: state.selectedCategoryId!,
        date: state.selectedDate,
        isReimbursable: state.isReimbursable,
        receiptPath: state.receiptPath,
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

      // Only report if it's an unexpected error
      if (ErrorMapper.shouldReportError(e)) {
        await _errorReporting.reportUIError(
          'AddExpenseViewModel',
          'updateExpense',
          e,
          stackTrace: stackTrace,
          context: {
            'expenseId': oldExpense.id.toString(),
            'errorCode': ErrorMapper.getErrorCode(e),
          },
        );
      }

      state = state.copyWith(
        status: SubmissionStatus.error,
        errorMessage: ErrorMapper.getUserFriendlyMessage(e),
      );
    }
  }

  /// Reset state (deprecated - use resetForm)
  @Deprecated('Use resetForm() instead')
  void resetState() {
    resetForm();
  }
}
