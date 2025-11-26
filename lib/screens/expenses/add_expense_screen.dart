import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:drift/drift.dart' as drift;
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:intl/intl.dart';

class AddExpenseScreen extends StatefulWidget {
  final AppDatabase database;
  final Function(int)? onNavigate;

  const AddExpenseScreen({required this.database, this.onNavigate, super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  int? _selectedCategoryId;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
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

      await widget.database.expenseDao.insertExpense(expense);

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
              onPressed: () {
                widget.onNavigate?.call(2); // Navigate to Expenses List
              },
            ),
          ),
        );
        // Clear form
        _amountController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedDate = DateTime.now();
          _selectedCategoryId = null;
        });
      }
    }
  }

  IconData _getIconFromCodePoint(String codePointStr) {
    try {
      final codePoint = int.parse(codePointStr);
      return IconData(codePoint, fontFamily: 'MaterialIcons');
    } catch (e) {
      return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New Expense',
                  style: AppTextStyles.heading1,
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the details of your transaction',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 32),

                // Amount Field
                Text('Amount', style: AppTextStyles.label),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  style: AppTextStyles.bodyLarge,
                  decoration: InputDecoration(
                    hintText: '0.00',
                    suffixText: 'DZD',
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Category Dropdown
                Text('Category', style: AppTextStyles.label),
                const SizedBox(height: 8),
                StreamBuilder<List<Category>>(
                  stream: widget.database.categoryDao.watchAllCategories(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final categories = snapshot.data!;
                    return DropdownButtonFormField<int>(
                      value: _selectedCategoryId,
                      items: categories.map((category) {
                        return DropdownMenuItem(
                          value: category.id,
                          child: Row(
                            children: [
                              Icon(
                                _getIconFromCodePoint(category.iconCodePoint),
                                color: Color(category.color),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(category.name),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryId = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Select Category',
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primary),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Date Picker
                Text('Date', style: AppTextStyles.label),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _selectDate(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: AppColors.textSecondary),
                        const SizedBox(width: 12),
                        Text(
                          DateFormat('MMM dd, yyyy').format(_selectedDate),
                          style: AppTextStyles.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Description Field
                Text('Description', style: AppTextStyles.label),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  style: AppTextStyles.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'What was this expense for?',
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Clear form
                          _amountController.clear();
                          _descriptionController.clear();
                          setState(() {
                            _selectedDate = DateTime.now();
                            _selectedCategoryId = null;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Reset', style: AppTextStyles.button.copyWith(color: AppColors.textSecondary)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveExpense,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Text('Save Expense', style: AppTextStyles.button),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  }
}
