import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/database/daos/expense_dao.dart';
import 'package:expense_tracking_desktop_app/features/budget/repositories/i_category_repository.dart';
import 'package:expense_tracking_desktop_app/features/expenses/services/expense_service.dart';
import 'package:expense_tracking_desktop_app/features/expenses/widgets/expense_form_widget.dart';
import 'package:expense_tracking_desktop_app/features/shared/widgets/snackbars/success_snackbar.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';

class EditExpenseDialog extends StatefulWidget {
  final ExpenseService expenseService;
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
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
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            const Divider(color: AppColors.border),
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
                    foregroundColor: AppColors.textSecondary,
                  ),
                  child: Text(AppStrings.btnCancel),
                ),
                const SizedBox(width: AppSpacing.md),
                ElevatedButton(
                  onPressed: _updateExpense,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                  ),
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
