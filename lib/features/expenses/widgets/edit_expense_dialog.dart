import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/features/expenses/services/i_expense_service.dart';
import 'package:expense_tracking_desktop_app/features/budget/repositories/i_category_repository.dart';
import 'package:expense_tracking_desktop_app/features/expenses/widgets/expense_form_widget.dart';
import 'package:expense_tracking_desktop_app/features/shared/widgets/snackbars/success_snackbar.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';
import 'package:expense_tracking_desktop_app/widgets/buttons.dart';

class EditExpenseDialog extends StatefulWidget {
  final IExpenseService expenseService;
  final ICategoryRepository categoryRepository;
  final ExpenseWithCategory expenseWithCategory;

  const EditExpenseDialog({
    super.key,
    required this.expenseService,
    required this.categoryRepository,
    required this.expenseWithCategory,
  });

  @override
  State<EditExpenseDialog> createState() => _EditExpenseDialogState();
}

class _EditExpenseDialogState extends State<EditExpenseDialog> {
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
        final colorScheme = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please select a category'),
            backgroundColor: colorScheme.error,
          ),
        );
        return;
      }

      try {
        final amount = double.parse(_amountController.text);
        
        // Validate amount is positive
        if (amount <= 0) {
          final colorScheme = Theme.of(context).colorScheme;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Amount must be greater than 0'),
              backgroundColor: colorScheme.error,
            ),
          );
          return;
        }
        
        // Validate date is reasonable
        final now = DateTime.now();
        final futureLimit = DateTime(now.year + 1, now.month, now.day);
        final pastLimit = DateTime(now.year - 10, now.month, now.day);
        
        if (_selectedDate.isAfter(futureLimit)) {
          final colorScheme = Theme.of(context).colorScheme;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Date cannot be more than 1 year in the future'),
              backgroundColor: colorScheme.error,
            ),
          );
          return;
        }
        
        if (_selectedDate.isBefore(pastLimit)) {
          final colorScheme = Theme.of(context).colorScheme;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Date cannot be more than 10 years in the past'),
              backgroundColor: colorScheme.error,
            ),
          );
          return;
        }
        
        final description = _descriptionController.text;

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
          Navigator.pop(context);
          SuccessSnackbar.show(context, 'Expense updated successfully');
        }
      } catch (e) {
        if (mounted) {
          final colorScheme = Theme.of(context).colorScheme;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update expense: ${e.toString()}'),
              backgroundColor: colorScheme.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Dialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppStrings.titleEditExpense,
                    style: AppTextStyles.heading3),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  color: colorScheme.onSurfaceVariant,
                  tooltip: 'Close',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Divider(color: colorScheme.outlineVariant),
            const SizedBox(height: AppSpacing.xl),
            Expanded(
              child: SingleChildScrollView(
                child: ExpenseFormWidget(
                  formKey: _formKey,
                  amountController: _amountController,
                  descriptionController: _descriptionController,
                  selectedDate: _selectedDate,
                  selectedCategoryId: _selectedCategoryId,
                  onDateChanged: (date) => setState(() => _selectedDate = date),
                  onCategoryChanged: (categoryId) =>
                      setState(() => _selectedCategoryId = categoryId),
                  onSubmit: () {}, // Handled by dialog buttons
                  onReset: () {}, // Handled by dialog buttons
                  isEditing: true,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.onSurfaceVariant,
                  ),
                  child: Text(AppStrings.btnCancel),
                ),
                const SizedBox(width: AppSpacing.md),
                PrimaryButton(
                  onPressed: _updateExpense,
                  child: Text('Update Expense'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
