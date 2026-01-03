import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/features/expenses/services/i_expense_service.dart';
import 'package:expense_tracking_desktop_app/features/expenses/services/budget_validation_service.dart';
import 'package:expense_tracking_desktop_app/features/expenses/providers/add_expense_provider.dart';
import 'package:expense_tracking_desktop_app/features/expenses/models/receipt_attachment.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';
import 'package:expense_tracking_desktop_app/services/logger_service.dart';
import 'package:expense_tracking_desktop_app/services/error_reporting_service.dart';
import 'package:expense_tracking_desktop_app/core/validators/expense_validators.dart';
import 'package:expense_tracking_desktop_app/core/errors/error_mapper.dart';
import 'dart:io';

class AddExpenseViewModel extends StateNotifier<AddExpenseState> {
  final IExpenseService _expenseService;
  final BudgetValidationService _budgetValidation;
  final ErrorReportingService _errorReporting;
  final AppDatabase _database; // Added: for receipt management
  final _logger = LoggerService.instance;

  AddExpenseViewModel(
    this._expenseService,
    this._budgetValidation,
    this._errorReporting,
    this._database,
    int? preSelectedCategoryId,
  ) : super(AddExpenseState.initial(
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

  /// Update receipt path (backward compatibility)
  void updateReceiptPath(String? path) {
    state = state.copyWith(
      receiptPath: path,
      clearReceiptPath: path == null,
    );
  }

  /// Remove receipt (backward compatibility)
  void removeReceipt() {
    state = state.copyWith(clearReceiptPath: true, receipts: []);
  }

  /// Add multiple receipts from file paths
  void addReceipts(List<String> filePaths) {
    final newReceipts = filePaths.map((path) => ReceiptAttachment.fromFilePath(path)).toList();
    final updatedReceipts = [...state.receipts, ...newReceipts];
    state = state.copyWith(receipts: updatedReceipts);
    _logger.info('AddExpenseViewModel: Added ${newReceipts.length} receipts (total: ${updatedReceipts.length})');
  }

  /// Add a single receipt from file path
  void addReceipt(String filePath) {
    addReceipts([filePath]);
  }

  /// Remove a specific receipt by index
  void removeReceiptAt(int index) {
    if (index >= 0 && index < state.receipts.length) {
      final updatedReceipts = List<ReceiptAttachment>.from(state.receipts);
      updatedReceipts.removeAt(index);
      state = state.copyWith(receipts: updatedReceipts);
      _logger.info('AddExpenseViewModel: Removed receipt at index $index');
    }
  }

  /// Clear all receipts
  void clearReceipts() {
    state = state.copyWith(receipts: []);
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
      receipts: [],
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

    // Parse amount for budget validation
    final amount = double.parse(state.amountController.text);

    // CRITICAL: Validate budget before submission (prevents budget overruns)
    final budgetError = await _budgetValidation.validateExpenseAgainstBudget(
      amount,
      state.selectedCategoryId!,
    );
    if (budgetError != null) {
      state = state.copyWith(
        status: SubmissionStatus.error,
        errorMessage: budgetError,
      );
      _logger.warning('AddExpenseViewModel: Budget validation failed - $budgetError');
      return;
    }

    // Set submitting status
    state = state.copyWith(status: SubmissionStatus.submitting);

    try {
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
      
      // CRITICAL: Use transaction to ensure atomicity
      final expenseId = await _database.transaction(() async {
        // Create expense
        final id = await _expenseService.createExpense(expense);
        
        // Save receipts if any
        if (state.receipts.isNotEmpty) {
          _logger.info('AddExpenseViewModel: Saving ${state.receipts.length} receipts');
          await _saveReceipts(id);
        }
        
        return id;
      });
      
      _logger.info('AddExpenseViewModel: Expense created successfully with ID $expenseId');

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

    // Parse amount for budget validation
    final amount = double.parse(state.amountController.text);

    // CRITICAL: Validate budget if amount or category changed
    if (amount != oldExpense.amount || state.selectedCategoryId != oldExpense.categoryId) {
      // Calculate the delta (new amount - old amount for same category)
      final amountDelta = state.selectedCategoryId == oldExpense.categoryId 
          ? amount - oldExpense.amount
          : amount; // Full amount if category changed
      
      if (amountDelta > 0) {
        final budgetError = await _budgetValidation.validateExpenseAgainstBudget(
          amountDelta,
          state.selectedCategoryId!,
        );
        if (budgetError != null) {
          state = state.copyWith(
            status: SubmissionStatus.error,
            errorMessage: budgetError,
          );
          _logger.warning('AddExpenseViewModel: Budget validation failed on update - $budgetError');
          return;
        }
      }
    }

    state = state.copyWith(status: SubmissionStatus.submitting);

    try {
      final newExpense = oldExpense.copyWith(
        amount: amount,
        description: state.descriptionController.text.trim(),
        categoryId: state.selectedCategoryId!,
        date: state.selectedDate,
        isReimbursable: state.isReimbursable,
        receiptPath: drift.Value(state.receiptPath),
      );

      await _expenseService.updateExpense(oldExpense, newExpense);
      _logger.info('AddExpenseViewModel: Expense updated successfully');

      // Note: Receipt updates on edit not yet implemented
      // Receipts remain unchanged when editing expense
      if (state.receipts.isNotEmpty) {
        _logger.info('AddExpenseViewModel: Receipt editing not yet implemented - receipts preserved');
      }

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

  /// Save receipts to database
  Future<void> _saveReceipts(int expenseId) async {
    try {
      final receiptsToSave = state.receipts.map((receipt) {
        // Get file size if possible
        int? fileSize;
        if (receipt.localPath != null) {
          try {
            final file = File(receipt.localPath!);
            fileSize = file.lengthSync();
          } catch (_) {}
        }

        return ReceiptsCompanion(
          expenseId: drift.Value(expenseId),
          localPath: drift.Value(receipt.localPath),
          remoteUrl: drift.Value(receipt.remoteUrl),
          fileName: drift.Value(receipt.fileName),
          fileType: drift.Value(receipt.fileType),
          fileSize: drift.Value(fileSize),
          uploadStatus: const drift.Value('local'),
        );
      }).toList();

      if (receiptsToSave.isNotEmpty) {
        await _database.receiptDao.insertMultipleReceipts(receiptsToSave);
        _logger.info('AddExpenseViewModel: Saved ${receiptsToSave.length} receipts to database');
      }
    } catch (e, stackTrace) {
      _logger.error('AddExpenseViewModel: Failed to save receipts',
          error: e, stackTrace: stackTrace);
      // Don't fail expense creation if receipts fail to save
    }
  }
}
