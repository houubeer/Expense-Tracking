import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';
import 'package:expense_tracking_desktop_app/features/expenses/widgets/expense_form_widget.dart';
import 'package:expense_tracking_desktop_app/features/expenses/providers/add_expense_provider.dart';
import 'package:expense_tracking_desktop_app/constants/app_routes.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final int? preSelectedCategoryId;

  const AddExpenseScreen({
    this.preSelectedCategoryId,
    super.key,
  });

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _pickReceiptFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        allowMultiple: true, // Enable multiple file selection
      );

      if (result != null && result.files.isNotEmpty) {
        final filePaths = result.files
            .where((f) => f.path != null)
            .map((f) => f.path!)
            .toList();

        if (filePaths.isNotEmpty) {
          ref
              .read(addExpenseViewModelProvider(widget.preSelectedCategoryId)
                  .notifier)
              .addReceipts(filePaths);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick file: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    ref.listen<AddExpenseState>(
      addExpenseViewModelProvider(widget.preSelectedCategoryId),
      (previous, next) {
        if (next.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.successMessage ?? AppStrings.msgExpenseAdded),
              backgroundColor: colorScheme.tertiary,
              action: SnackBarAction(
                label: AppStrings.navViewExpenses,
                textColor: Colors.white,
                onPressed: () => context.go(AppRoutes.viewExpenses),
              ),
            ),
          );
          // Reset form after successful submission
          ref
              .read(addExpenseViewModelProvider(widget.preSelectedCategoryId)
                  .notifier)
              .resetForm(preSelectedCategoryId: widget.preSelectedCategoryId);
        } else if (next.isError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.errorMessage ?? 'An error occurred'),
              backgroundColor: colorScheme.error,
            ),
          );
        }
      },
    );

    final state =
        ref.watch(addExpenseViewModelProvider(widget.preSelectedCategoryId));
    final viewModel = ref.read(
        addExpenseViewModelProvider(widget.preSelectedCategoryId).notifier);

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: Center(
        child: ExpenseFormWidget(
          formKey: _formKey,
          amountController: state.amountController,
          descriptionController: state.descriptionController,
          selectedDate: state.selectedDate,
          selectedCategoryId: state.selectedCategoryId,
          onDateChanged: viewModel.updateDate,
          onCategoryChanged: viewModel.updateCategory,
          isReimbursable: state.isReimbursable,
          onReimbursableChanged: viewModel.updateReimbursable,
          receiptPath: state.receiptPath,
          receipts: state.receipts, // Pass receipts list
          onAttachReceipt: _pickReceiptFile,
          onRemoveReceipt: viewModel.removeReceipt,
          onRemoveReceiptAt: viewModel.removeReceiptAt, // Pass new method
          onSubmit: state.isSubmitting
              ? null
              : () async {
                  if (_formKey.currentState!.validate() &&
                      state.selectedCategoryId != null) {
                    await viewModel.submitExpense();
                  } else if (state.selectedCategoryId == null) {
                    final errorColorScheme = Theme.of(context).colorScheme;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Please select a category'),
                        backgroundColor: errorColorScheme.error,
                      ),
                    );
                  }
                },
          onReset: () => viewModel.resetForm(
              preSelectedCategoryId: widget.preSelectedCategoryId),
          isSubmitting: state.isSubmitting,
        ),
      ),
    );
  }
}
