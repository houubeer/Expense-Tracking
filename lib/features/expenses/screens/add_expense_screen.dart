import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import 'package:go_router/go_router.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/features/expenses/widgets/expense_form_widget.dart';
import 'package:expense_tracking_desktop_app/features/expenses/repositories/expense_repository.dart';
import 'package:expense_tracking_desktop_app/routes/app_routes.dart';

class AddExpenseScreen extends StatefulWidget {
  final AppDatabase database;
  final int? preSelectedCategoryId;

  const AddExpenseScreen({
    required this.database,
    this.preSelectedCategoryId,
    super.key,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  int? _selectedCategoryId;
  late ExpenseRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = ExpenseRepository(widget.database);
    _selectedCategoryId = widget.preSelectedCategoryId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveExpense() async {
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

      final expense = ExpensesCompanion(
        amount: drift.Value(amount),
        description: drift.Value(description),
        date: drift.Value(_selectedDate),
        categoryId: drift.Value(_selectedCategoryId!),
      );

      await _repository.insertExpense(expense);

      // Update category spent amount
      final category = await widget.database.categoryDao
          .getCategoryById(_selectedCategoryId!);
      if (category != null) {
        await widget.database.categoryDao
            .updateCategorySpent(category.id, category.spent + amount);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Expense added successfully'),
            backgroundColor: AppColors.green,
            action: SnackBarAction(
              label: 'View Expenses',
              textColor: Colors.white,
              onPressed: () => context.go(AppRoutes.viewExpenses),
            ),
          ),
        );
        _resetForm();
      }
    }
  }

  void _resetForm() {
    _amountController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedDate = DateTime.now();
      _selectedCategoryId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ExpenseFormWidget(
          database: widget.database,
          formKey: _formKey,
          amountController: _amountController,
          descriptionController: _descriptionController,
          selectedDate: _selectedDate,
          selectedCategoryId: _selectedCategoryId,
          onDateChanged: (date) => setState(() => _selectedDate = date),
          onCategoryChanged: (id) => setState(() => _selectedCategoryId = id),
          onSubmit: _saveExpense,
          onReset: _resetForm,
        ),
      ),
    );
  }
}
