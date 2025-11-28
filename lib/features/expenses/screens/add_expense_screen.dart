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
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.preSelectedCategoryId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    final viewModel = ref.read(addExpenseViewModelProvider.notifier);
    final amount = double.parse(_amountController.text);
    final description = _descriptionController.text;

    await viewModel.submitExpense(
      amount: amount,
      description: description,
      date: _selectedDate,
      categoryId: _selectedCategoryId!,
    );
  }

  void _resetForm() {
    _amountController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedDate = DateTime.now();
      _selectedCategoryId = widget.preSelectedCategoryId;
    });
    ref.read(addExpenseViewModelProvider.notifier).resetState();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AddExpenseState>(
      addExpenseViewModelProvider,
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
          _resetForm();
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

    final state = ref.watch(addExpenseViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ExpenseFormWidget(
          formKey: _formKey,
          amountController: _amountController,
          descriptionController: _descriptionController,
          selectedDate: _selectedDate,
          selectedCategoryId: _selectedCategoryId,
          onDateChanged: (date) => setState(() => _selectedDate = date),
          onCategoryChanged: (id) => setState(() => _selectedCategoryId = id),
          onSubmit: state.isSubmitting ? null : _saveExpense,
          onReset: _resetForm,
          isSubmitting: state.isSubmitting,
        ),
      ),
    );
  }
}
