import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/database/daos/expense_dao.dart';
import 'package:expense_tracking_desktop_app/screens/expenses/edit_expense_screen.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/widgets/dialogs/expense_detail_dialog.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' as drift;
import '../../repositories/expense_repository.dart';
import '../../widgets/success_snackbar.dart';

class ExpensesListScreen extends StatefulWidget {
  final AppDatabase database;
  final Function(int)? onNavigate;

  const ExpensesListScreen(
      {required this.database, this.onNavigate, super.key});

  @override
  State<ExpensesListScreen> createState() => _ExpensesListScreenState();
}

class _ExpensesListScreenState extends State<ExpensesListScreen> {
  late ExpenseRepository _repository;
  String _searchQuery = '';

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

            // Search Bar
            Container(
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
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search transactions...',
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                  prefixIcon:
                      Icon(Icons.search, color: AppColors.textSecondary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
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
              child: StreamBuilder<List<ExpenseWithCategory>>(
                stream: _repository.watchExpensesWithCategory(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final expenses = snapshot.data ?? [];

                  // Filter expenses
                  final filteredExpenses = expenses.where((item) {
                    final matchesSearch = item.expense.description
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()) ||
                        item.category.name
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase());
                    return matchesSearch;
                  }).toList();

                  if (filteredExpenses.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_outlined,
                              size: 64,
                              color: AppColors.textSecondary.withOpacity(0.5)),
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

  Widget _buildExpenseRow(ExpenseWithCategory item) {
    final categoryColor = Color(item.category.color);
    final dateStr = DateFormat('MMM dd, yyyy').format(item.expense.date);

    return Container(
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
              "${item.expense.amount.toStringAsFixed(2)}",
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
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditExpenseScreen(
                          database: widget.database,
                          expenseWithCategory: item,
                        ),
                      ),
                    );
                    if (result == true) {
                      setState(() {
                        // Trigger rebuild to show updated data
                        // StreamBuilder will handle it, but setState ensures UI refresh if needed
                      });
                    }
                  },
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

  IconData _getIconFromCodePoint(String codePointStr) {
    try {
      final codePoint = int.parse(codePointStr);
      return IconData(codePoint, fontFamily: 'MaterialIcons');
    } catch (e) {
      return Icons.category;
    }
  }

  void _confirmDelete(ExpenseWithCategory item) {
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
            child: Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog first
              await _repository.deleteExpense(item.expense.id);

              if (mounted) {
                SuccessSnackbar.show(context, 'Transaction deleted',
                    onUndo: () async {
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
                });
              }
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
