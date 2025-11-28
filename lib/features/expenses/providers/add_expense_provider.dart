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

  const AddExpenseState({
    required this.status,
    this.errorMessage,
    this.successMessage,
  });

  factory AddExpenseState.initial() {
    return const AddExpenseState(status: SubmissionStatus.idle);
  }

  AddExpenseState copyWith({
    SubmissionStatus? status,
    String? errorMessage,
    String? successMessage,
  }) {
    return AddExpenseState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  bool get isSubmitting => status == SubmissionStatus.submitting;
  bool get isSuccess => status == SubmissionStatus.success;
  bool get isError => status == SubmissionStatus.error;
  bool get isIdle => status == SubmissionStatus.idle;
}

/// ViewModel Provider - manages form submission and state
final addExpenseViewModelProvider =
    StateNotifierProvider.autoDispose<AddExpenseViewModel, AddExpenseState>(
  (ref) {
    final expenseService = ref.watch(expenseServiceProvider);
    return AddExpenseViewModel(expenseService);
  },
);
