import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/database/daos/expense_dao.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/features/expenses/widgets/expense_form_widget.dart';
import 'package:expense_tracking_desktop_app/features/shared/widgets/common/success_snackbar.dart';
import 'package:expense_tracking_desktop_app/features/expenses/services/expense_service.dart';
import 'package:expense_tracking_desktop_app/features/budget/repositories/i_category_repository.dart';

class EditExpenseScreen extends StatefulWidget {
  final ExpenseService expenseService;
  final ICategoryRepository categoryRepository;
  final ExpenseWithCategory expenseWithCategory;
  final Function(int)? onNavigate;

  const EditExpenseScreen({
    required this.expenseService,
    required this.categoryRepository,
    required this.expenseWithCategory,
    this.onNavigate,
    super.key,
  });

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    final expense = widget.expenseWithCategory.expense;
    _amountController = TextEditingController(text: expense.amount.toString());
    _descriptionController = TextEditingController(text: expense.description);
    _selectedDate = expense.date;
    _selectedCategoryId = expense.categoryId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _updateExpense() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a category'),
            backgroundColor: AppColors.red,
          ),
        );
        return;
      }

      final amount = double.parse(_amountController.text);
      final description = _descriptionController.text;

      // Create updated expense object
      // We need to preserve the ID and createdAt
      final originalExpense = widget.expenseWithCategory.expense;
      final updatedExpense = originalExpense.copyWith(
        amount: amount,
        description: description,
        date: _selectedDate,
        categoryId: _selectedCategoryId!,
      );

      await widget.expenseService
          .updateExpense(originalExpense, updatedExpense);

      if (mounted) {
        SuccessSnackbar.show(context, 'Expense updated successfully');
        Navigator.pop(context, true); // Return true to indicate update
      }
    }
  }

  void _resetForm() {
    // Reset to original values
    final expense = widget.expenseWithCategory.expense;
    _amountController.text = expense.amount.toString();
    _descriptionController.text = expense.description;
    setState(() {
      _selectedDate = expense.date;
      _selectedCategoryId = expense.categoryId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Edit Transaction', style: AppTextStyles.heading3),
      ),
      body: Center(
        child: ExpenseFormWidget(
          formKey: _formKey,
          amountController: _amountController,
          descriptionController: _descriptionController,
          selectedDate: _selectedDate,
          selectedCategoryId: _selectedCategoryId,
          onDateChanged: (date) => setState(() => _selectedDate = date),
          onCategoryChanged: (id) => setState(() => _selectedCategoryId = id),
          onSubmit: _updateExpense,
          onReset: _resetForm,
          isEditing: true,
        ),
      ),
    );
  }
}
