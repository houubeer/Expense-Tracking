import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/features/expenses/services/i_expense_service.dart';
import 'package:expense_tracking_desktop_app/features/budget/repositories/i_category_repository.dart';
import 'package:expense_tracking_desktop_app/features/expenses/widgets/expense_form_widget.dart';
import 'package:expense_tracking_desktop_app/features/shared/widgets/snackbars/success_snackbar.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/l10n/app_localizations.dart';
import 'package:expense_tracking_desktop_app/widgets/buttons.dart';

class EditExpenseDialog extends StatefulWidget {
  const EditExpenseDialog({
    required this.expenseService,
    required this.categoryRepository,
    required this.expenseWithCategory,
    super.key,
  });
  final IExpenseService expenseService;
  final ICategoryRepository categoryRepository;
  final ExpenseWithCategory expenseWithCategory;

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
            content: Text(AppLocalizations.of(context)!.errCategoryRequired),
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
              content: Text(AppLocalizations.of(context)!.errAmountPositive),
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
              content: Text(AppLocalizations.of(context)!.errDateFuture),
              backgroundColor: colorScheme.error,
            ),
          );
          return;
        }

        if (_selectedDate.isBefore(pastLimit)) {
          final colorScheme = Theme.of(context).colorScheme;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.errDatePast),
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
          categoryId: _selectedCategoryId,
        );

        await widget.expenseService
            .updateExpense(originalExpense, updatedExpense);

        if (mounted) {
          Navigator.pop(context);
          SuccessSnackbar.show(
              context, AppLocalizations.of(context)!.msgExpenseUpdated);
        }
      } catch (e) {
        if (mounted) {
          final colorScheme = Theme.of(context).colorScheme;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  AppLocalizations.of(context)!.errUpdateExpense(e.toString())),
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
                Text(
                  AppLocalizations.of(context)!.titleEditExpense,
                  style: AppTextStyles.heading3,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  color: colorScheme.onSurfaceVariant,
                  tooltip: AppLocalizations.of(context)!.tooltipClose,
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
                  child: Text(AppLocalizations.of(context)!.btnCancel),
                ),
                const SizedBox(width: AppSpacing.md),
                PrimaryButton(
                  onPressed: _updateExpense,
                  child: Text(AppLocalizations.of(context)!.btnUpdateExpense),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
