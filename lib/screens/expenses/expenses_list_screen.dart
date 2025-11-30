import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/features/expenses/widgets/expense_detail_dialog.dart';
import 'package:expense_tracking_desktop_app/features/expenses/services/i_expense_service.dart'
    as service;
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' as drift;
import 'package:expense_tracking_desktop_app/features/expenses/repositories/expense_repository.dart';
import 'package:expense_tracking_desktop_app/features/shared/widgets/snackbars/success_snackbar.dart';
import 'package:expense_tracking_desktop_app/features/expenses/widgets/expense_form_widget.dart';

class ExpensesListScreen extends StatefulWidget {
  final AppDatabase database;
  final Function(int, {int? categoryId})? onNavigate;

  const ExpensesListScreen(
      {required this.database, this.onNavigate, super.key});

  @override
  State<ExpensesListScreen> createState() => _ExpensesListScreenState();
}

class _ExpensesListScreenState extends State<ExpensesListScreen> {
  late ExpenseRepository _repository;
  String _searchQuery = '';
  int? _selectedCategoryFilter;
  DateTime? _selectedDateFilter;

  @override
  void initState() {
    super.initState();
    _repository = ExpenseRepository(widget.database);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transactions',
                      style: AppTextStyles.heading1,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'View and manage your expense history',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    if (widget.onNavigate != null) {
                      widget.onNavigate!(1); // Navigate to Add Expense
                    }
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Add Expense"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: AppTextStyles.button,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Search Bar and Filters Row
            Row(
              children: [
                // Search Bar
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                      decoration: const InputDecoration(
                        hintText: 'Search transactions...',
                        hintStyle: TextStyle(color: AppColors.textSecondary),
                        prefixIcon:
                            Icon(Icons.search, color: AppColors.textSecondary),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Category Filter
                Expanded(
                  flex: 2,
                  child: StreamBuilder<List<Category>>(
                    stream: widget.database.categoryDao.watchAllCategories(),
                    builder: (context, snapshot) {
                      final categories = snapshot.data ?? [];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int?>(
                            value: _selectedCategoryFilter,
                            hint: const Row(
                              children: [
                                Icon(Icons.filter_list,
                                    color: AppColors.textSecondary, size: 20),
                                SizedBox(width: 8),
                                Text('Category',
                                    style: TextStyle(
                                        color: AppColors.textSecondary)),
                              ],
                            ),
                            isExpanded: true,
                            items: [
                              const DropdownMenuItem<int?>(
                                value: null,
                                child: Row(
                                  children: [
                                    Icon(Icons.clear,
                                        color: AppColors.textSecondary,
                                        size: 20),
                                    SizedBox(width: 8),
                                    Text('All Categories'),
                                  ],
                                ),
                              ),
                              ...categories.map((category) {
                                return DropdownMenuItem<int?>(
                                  value: category.id,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: Color(category.color),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(category.name),
                                    ],
                                  ),
                                );
                              }),
                            ],
                            onChanged: (value) {
                              setState(() => _selectedCategoryFilter = value);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Date Filter
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDateFilter ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null) {
                          setState(() => _selectedDateFilter = picked);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                color: AppColors.textSecondary, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _selectedDateFilter == null
                                    ? 'Date'
                                    : DateFormat('MMM dd, yyyy')
                                        .format(_selectedDateFilter!),
                                style: TextStyle(
                                  color: _selectedDateFilter == null
                                      ? AppColors.textSecondary
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (_selectedDateFilter != null)
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedDateFilter = null),
                                child: const Icon(Icons.close,
                                    color: AppColors.textSecondary, size: 18),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Table Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                      flex: 2, child: Text('Date', style: AppTextStyles.label)),
                  Expanded(
                      flex: 2,
                      child: Text('Category', style: AppTextStyles.label)),
                  Expanded(
                      flex: 3,
                      child: Text('Description', style: AppTextStyles.label)),
                  Expanded(
                      flex: 2,
                      child: Text('Amount', style: AppTextStyles.label)),
                  SizedBox(
                      width: 100,
                      child: Text('Actions',
                          style: AppTextStyles.label,
                          textAlign: TextAlign.end)),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Expenses List
            Expanded(
              child: StreamBuilder<List<service.ExpenseWithCategory>>(
                stream: _repository.watchExpensesWithCategory(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final expenses = snapshot.data ?? [];

                  // Filter expenses
                  final filteredExpenses = expenses.where((item) {
                    // Search filter
                    final matchesSearch = item.expense.description
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()) ||
                        item.category.name
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase());

                    // Category filter
                    final matchesCategory = _selectedCategoryFilter == null ||
                        item.category.id == _selectedCategoryFilter;

                    // Date filter
                    final matchesDate = _selectedDateFilter == null ||
                        (item.expense.date.year == _selectedDateFilter!.year &&
                            item.expense.date.month ==
                                _selectedDateFilter!.month &&
                            item.expense.date.day == _selectedDateFilter!.day);

                    return matchesSearch && matchesCategory && matchesDate;
                  }).toList();

                  if (filteredExpenses.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_outlined,
                              size: 64,
                              color: AppColors.textSecondary
                                  .withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          Text(
                            'No transactions found',
                            style: AppTextStyles.heading3
                                .copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: filteredExpenses.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1, color: AppColors.border),
                    itemBuilder: (context, index) {
                      final item = filteredExpenses[index];
                      return _buildExpenseRow(item);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseRow(service.ExpenseWithCategory item) {
    final categoryColor = Color(item.category.color);
    final dateStr = DateFormat('MMM dd, yyyy').format(item.expense.date);

    return InkWell(
      onTap: () => _showExpenseDetail(item),
      hoverColor: AppColors.primary.withValues(alpha: 0.03),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            // Date
            Expanded(
              flex: 2,
              child: Text(
                dateStr,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textPrimary),
              ),
            ),
            // Category
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getIconFromCodePoint(item.category.iconCodePoint),
                        color: categoryColor,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.category.name,
                        style: AppTextStyles.caption.copyWith(
                          color: categoryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Description
            Expanded(
              flex: 3,
              child: Text(
                item.expense.description,
                style: AppTextStyles.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Amount
            Expanded(
              flex: 2,
              child: Text(
                item.expense.amount.toStringAsFixed(2),
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            // Actions
            SizedBox(
              width: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        size: 20, color: AppColors.primary),
                    onPressed: () => _showEditExpenseDialog(item),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        size: 20, color: AppColors.red),
                    onPressed: () => _confirmDelete(item),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExpenseDetail(service.ExpenseWithCategory item) {
    showDialog(
      context: context,
      builder: (context) => ExpenseDetailDialog(
        expenseWithCategory: item,
      ),
    );
  }

  void _showEditExpenseDialog(service.ExpenseWithCategory item) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _EditExpenseDialog(
        database: widget.database,
        expenseWithCategory: item,
      ),
    );
  }

  IconData _getIconFromCodePoint(String codePointStr) {
    try {
      final codePoint = int.parse(codePointStr);
      return IconData(codePoint, fontFamily: 'MaterialIcons');
    } catch (e) {
      return Icons.category;
    }
  }

  void _confirmDelete(service.ExpenseWithCategory item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Delete Transaction', style: AppTextStyles.heading3),
        content: const Text(
            'Are you sure you want to delete this transaction? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          FilledButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final bgColor = Theme.of(context).colorScheme.secondary;
              Navigator.pop(context); // Close dialog first
              await _repository.deleteExpense(item.expense.id);

              if (!mounted) return;

              messenger.showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Transaction deleted',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: bgColor,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 3),
                  action: SnackBarAction(
                    label: 'Undo',
                    textColor: Colors.white,
                    onPressed: () async {
                      // Re-insert the expense
                      final expense = ExpensesCompanion(
                        amount: drift.Value(item.expense.amount),
                        date: drift.Value(item.expense.date),
                        description: drift.Value(item.expense.description),
                        categoryId: drift.Value(item.expense.categoryId),
                        createdAt: drift.Value(item.expense.createdAt),
                        // We don't set ID to let it auto-increment, or we could try to force it if needed.
                        // Usually for undo, a new ID is fine unless order matters strictly by ID.
                        // But wait, if we want to restore it exactly, we might want the same ID.
                        // However, autoIncrement columns usually don't let you insert explicit values easily
                        // without specific mode. Let's stick to re-creating it.
                      );
                      await _repository.insertExpense(expense);
                    },
                  ),
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _EditExpenseDialog extends StatefulWidget {
  final AppDatabase database;
  final service.ExpenseWithCategory expenseWithCategory;

  const _EditExpenseDialog({
    required this.database,
    required this.expenseWithCategory,
  });

  @override
  State<_EditExpenseDialog> createState() => _EditExpenseDialogState();
}

class _EditExpenseDialogState extends State<_EditExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  int? _selectedCategoryId;
  late ExpenseRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = ExpenseRepository(widget.database);
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

      await _repository.updateExpense(updatedExpense);

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
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Edit Transaction', style: AppTextStyles.heading3),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(color: AppColors.border),
            const SizedBox(height: 24),
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
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                  ),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _updateExpense,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Update Expense'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
//hi
