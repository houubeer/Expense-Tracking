import 'package:expense_tracking_desktop_app/features/expenses/providers/add_expense_provider.dart';
import 'package:expense_tracking_desktop_app/features/expenses/services/i_expense_service.dart';
import 'package:expense_tracking_desktop_app/features/expenses/view_models/add_expense_view_model.dart';
import 'package:expense_tracking_desktop_app/services/error_reporting_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'add_expense_view_model_test.mocks.dart';

@GenerateMocks([IExpenseService, ErrorReportingService])
void main() {
  late MockIExpenseService mockExpenseService;
  late MockErrorReportingService mockErrorReportingService;
  late AddExpenseViewModel viewModel;

  setUp(() {
    mockExpenseService = MockIExpenseService();
    mockErrorReportingService = MockErrorReportingService();
    viewModel = AddExpenseViewModel(
      mockExpenseService,
      mockErrorReportingService,
      null,
    );
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('AddExpenseViewModel', () {
    test('initial state is correct', () {
      expect(viewModel.state.status, SubmissionStatus.idle);
      expect(viewModel.state.amountController.text, isEmpty);
      expect(viewModel.state.descriptionController.text, isEmpty);
      expect(viewModel.state.selectedCategoryId, isNull);
    });

    test('updateDate updates state', () {
      final date = DateTime(2023, 1, 1);
      viewModel.updateDate(date);
      expect(viewModel.state.selectedDate, date);
    });

    test('updateCategory updates state', () {
      viewModel.updateCategory(1);
      expect(viewModel.state.selectedCategoryId, 1);
    });

    // Validation is now done via ExpenseValidators class
    // See expense_validators_test.dart for validation tests

    test('submitExpense fails with validation errors', () async {
      // Empty form
      await viewModel.submitExpense();
      expect(viewModel.state.status, SubmissionStatus.error);
      expect(viewModel.state.errorMessage, 'Please enter an amount');

      // Invalid amount
      viewModel.state.amountController.text = 'abc';
      await viewModel.submitExpense();
      expect(viewModel.state.status, SubmissionStatus.error);
      expect(viewModel.state.errorMessage, 'Please enter a valid number');

      // Valid amount, missing category
      viewModel.state.amountController.text = '100';
      await viewModel.submitExpense();
      expect(viewModel.state.status, SubmissionStatus.error);
      expect(viewModel.state.errorMessage, 'Please select a category');
    });

    test('submitExpense succeeds with valid data', () async {
      viewModel.state.amountController.text = '100';
      viewModel.state.descriptionController.text = 'Test Expense';
      viewModel.updateCategory(1);

      when(mockExpenseService.createExpense(any)).thenAnswer((_) async => 1);

      await viewModel.submitExpense();

      verify(mockExpenseService.createExpense(any)).called(1);
      expect(viewModel.state.status, SubmissionStatus.success);
    });

    test('submitExpense handles service errors', () async {
      viewModel.state.amountController.text = '100';
      viewModel.state.descriptionController.text = 'Test Expense';
      viewModel.updateCategory(1);

      final error = Exception('Database error');
      when(mockExpenseService.createExpense(any)).thenThrow(error);

      // Mock error reporting
      when(mockErrorReportingService.reportUIError(
        any,
        any,
        any,
        stackTrace: anyNamed('stackTrace'),
        context: anyNamed('context'),
      )).thenAnswer((_) async {});

      await viewModel.submitExpense();

      verify(mockExpenseService.createExpense(any)).called(1);
      expect(viewModel.state.status, SubmissionStatus.error);
      expect(viewModel.state.errorMessage, contains('Failed to add expense'));
    });
  });
}
