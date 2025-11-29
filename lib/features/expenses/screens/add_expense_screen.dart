import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
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

  @override
  Widget build(BuildContext context) {
    ref.listen<AddExpenseState>(
      addExpenseViewModelProvider(widget.preSelectedCategoryId),
      (previous, next) {
        if (next.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.successMessage ?? AppStrings.msgExpenseAdded),
              backgroundColor: AppColors.green,
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
              backgroundColor: AppColors.red,
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
      backgroundColor: AppColors.background,
      body: Center(
        child: ExpenseFormWidget(
          formKey: _formKey,
          amountController: state.amountController,
          descriptionController: state.descriptionController,
          selectedDate: state.selectedDate,
          selectedCategoryId: state.selectedCategoryId,
          onDateChanged: viewModel.updateDate,
          onCategoryChanged: viewModel.updateCategory,
          onSubmit: state.isSubmitting
              ? null
              : () async {
                  if (_formKey.currentState!.validate() &&
                      state.selectedCategoryId != null) {
                    await viewModel.submitExpense();
                  } else if (state.selectedCategoryId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a category'),
                        backgroundColor: AppColors.red,
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
