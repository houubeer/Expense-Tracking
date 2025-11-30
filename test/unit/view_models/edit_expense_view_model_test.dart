import 'package:drift/drift.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/features/expenses/providers/edit_expense_provider.dart';
import 'package:expense_tracking_desktop_app/features/expenses/services/i_expense_service.dart';
import 'package:expense_tracking_desktop_app/features/expenses/view_models/edit_expense_view_model.dart';
import 'package:expense_tracking_desktop_app/services/error_reporting_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'edit_expense_view_model_test.mocks.dart';

@GenerateMocks([IExpenseService, ErrorReportingService])
void main() {
  late MockIExpenseService mockExpenseService;
  late MockErrorReportingService mockErrorReporting;
  late EditExpenseViewModel viewModel;
  late Expense testExpense;

  setUp(() {
    mockExpenseService = MockIExpenseService();
    mockErrorReporting = MockErrorReportingService();

    testExpense = Expense(
      id: 1,
      amount: 100.0,
      description: 'Test Expense',
      date: DateTime.now(),
      categoryId: 1,
      createdAt: DateTime.now(),
    );

    viewModel = EditExpenseViewModel(
      mockExpenseService,
      mockErrorReporting,
      testExpense,
    );
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('EditExpenseViewModel', () {
    test('initial state contains expense data', () {
      expect(viewModel.state.status, EditStatus.idle);
      expect(viewModel.state.amountController.text, '100.0');
      expect(viewModel.state.descriptionController.text, 'Test Expense');
      expect(viewModel.state.selectedCategoryId, 1);
      expect(viewModel.state.selectedDate.day, testExpense.date.day);
    });

    test('updateDate updates state', () {
      final newDate = DateTime(2023, 6, 15);
      viewModel.updateDate(newDate);

      expect(viewModel.state.selectedDate, newDate);
    });

    test('updateCategory updates state', () {
      viewModel.updateCategory(2);

      expect(viewModel.state.selectedCategoryId, 2);
    });

    test('updateCategory clears when null', () {
      viewModel.updateCategory(null);

      expect(viewModel.state.selectedCategoryId, isNull);
    });

    test('validateAmount returns error for invalid input', () {
      expect(viewModel.validateAmount(null), 'Please enter an amount');
      expect(viewModel.validateAmount(''), 'Please enter an amount');
      expect(viewModel.validateAmount('abc'), 'Please enter a valid number');
      expect(viewModel.validateAmount('-10'), 'Amount must be greater than 0');
      expect(viewModel.validateAmount('0'), 'Amount must be greater than 0');
      expect(viewModel.validateAmount('50.50'), isNull);
    });

    test('validateCategory returns error when null', () {
      expect(viewModel.validateCategory(null), 'Please select a category');
      expect(viewModel.validateCategory(1), isNull);
    });

    test('submitUpdate succeeds with valid data', () async {
      viewModel.state.amountController.text = '150';
      viewModel.state.descriptionController.text = 'Updated Expense';
      viewModel.updateCategory(2);

      when(mockExpenseService.updateExpense(any, any)).thenAnswer((_) async {});

      await viewModel.submitUpdate();

      verify(mockExpenseService.updateExpense(any, any)).called(1);
      expect(viewModel.state.status, EditStatus.success);
    });

    test('submitUpdate fails with validation errors', () async {
      viewModel.state.amountController.clear();

      await viewModel.submitUpdate();

      expect(viewModel.state.status, EditStatus.error);
      expect(viewModel.state.errorMessage, 'Please enter an amount');
      verifyNever(mockExpenseService.updateExpense(any, any));
    });

    test('submitUpdate handles service errors', () async {
      viewModel.state.amountController.text = '150';
      viewModel.updateCategory(2);

      final error = Exception('Update failed');
      when(mockExpenseService.updateExpense(any, any)).thenThrow(error);
      when(mockErrorReporting.reportUIError(any, any, any,
              stackTrace: anyNamed('stackTrace'), context: anyNamed('context')))
          .thenAnswer((_) async {});

      await viewModel.submitUpdate();

      expect(viewModel.state.status, EditStatus.error);
      expect(
          viewModel.state.errorMessage, contains('Failed to update expense'));
      verify(mockErrorReporting.reportUIError(any, any, any,
              stackTrace: anyNamed('stackTrace'), context: anyNamed('context')))
          .called(1);
    });

    test('submitUpdate creates updated expense with changed values', () async {
      viewModel.state.amountController.text = '200';
      viewModel.state.descriptionController.text = 'New Description';
      viewModel.updateCategory(3);
      final newDate = DateTime(2023, 7, 20);
      viewModel.updateDate(newDate);

      Expense? capturedOld;
      Expense? capturedNew;

      when(mockExpenseService.updateExpense(any, any))
          .thenAnswer((invocation) async {
        capturedOld = invocation.positionalArguments[0] as Expense;
        capturedNew = invocation.positionalArguments[1] as Expense;
      });

      await viewModel.submitUpdate();

      expect(capturedOld, testExpense);
      expect(capturedNew!.amount, 200.0);
      expect(capturedNew!.description, 'New Description');
      expect(capturedNew!.categoryId, 3);
      expect(capturedNew!.date.day, newDate.day);
    });

    test('resetForm restores original expense data', () {
      // Modify state
      viewModel.state.amountController.text = '999';
      viewModel.state.descriptionController.text = 'Changed';
      viewModel.updateCategory(99);

      // Reset
      viewModel.resetForm();

      expect(viewModel.state.amountController.text, '100.0');
      expect(viewModel.state.descriptionController.text, 'Test Expense');
      expect(viewModel.state.selectedCategoryId, 1);
      expect(viewModel.state.status, EditStatus.idle);
    });
  });
}
