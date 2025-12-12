import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracking_desktop_app/providers/app_providers.dart';
import 'package:expense_tracking_desktop_app/features/expenses/view_models/add_expense_view_model.dart';

/// Submission status for form feedback
enum SubmissionStatus {
  idle,
  submitting,
  success,
  error,
}

/// Add Expense State - holds form state and submission status
class AddExpenseState {
  final SubmissionStatus status;
  final String? errorMessage;
  final String? successMessage;
  final TextEditingController amountController;
  final TextEditingController descriptionController;
  final DateTime selectedDate;
  final int? selectedCategoryId;
  final bool isReimbursable;
  final String? receiptPath;

  AddExpenseState({
    required this.status,
    this.errorMessage,
    this.successMessage,
    required this.amountController,
    required this.descriptionController,
    required this.selectedDate,
    this.selectedCategoryId,
    this.isReimbursable = false,
    this.receiptPath,
  });

  factory AddExpenseState.initial({int? preSelectedCategoryId}) {
    return AddExpenseState(
      status: SubmissionStatus.idle,
      amountController: TextEditingController(),
      descriptionController: TextEditingController(),
      selectedDate: DateTime.now(),
      selectedCategoryId: preSelectedCategoryId,
      isReimbursable: false,
      receiptPath: null,
    );
  }

  AddExpenseState copyWith({
    SubmissionStatus? status,
    String? errorMessage,
    String? successMessage,
    DateTime? selectedDate,
    int? selectedCategoryId,
    bool clearCategoryId = false,
    bool? isReimbursable,
    String? receiptPath,
    bool clearReceiptPath = false,
  }) {
    return AddExpenseState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      successMessage: successMessage,
      amountController: amountController,
      descriptionController: descriptionController,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedCategoryId: clearCategoryId
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
      isReimbursable: isReimbursable ?? this.isReimbursable,
      receiptPath: clearReceiptPath ? null : (receiptPath ?? this.receiptPath),
    );
  }

  bool get isSubmitting => status == SubmissionStatus.submitting;
  bool get isSuccess => status == SubmissionStatus.success;
  bool get isError => status == SubmissionStatus.error;
  bool get isIdle => status == SubmissionStatus.idle;
}

/// ViewModel Provider - manages form submission and state
final addExpenseViewModelProvider = StateNotifierProvider.autoDispose
    .family<AddExpenseViewModel, AddExpenseState, int?>(
  (ref, preSelectedCategoryId) {
    final expenseService = ref.watch(expenseServiceProvider);
    final errorReporting = ref.watch(errorReportingServiceProvider);
    return AddExpenseViewModel(
        expenseService, errorReporting, preSelectedCategoryId);
  },
);
