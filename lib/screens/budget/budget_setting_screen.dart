import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:drift/drift.dart' hide Column;

class BudgetSettingScreen extends StatefulWidget {
  final AppDatabase database;
  final Function(int, {int? categoryId})? onNavigate;

  const BudgetSettingScreen(
      {required this.database, this.onNavigate, super.key});

  @override
  State<BudgetSettingScreen> createState() => _BudgetSettingScreenState();
}

class _BudgetSettingScreenState extends State<BudgetSettingScreen> {
  final Map<int, TextEditingController> _controllers = {};
  String _searchQuery = '';
  String _filterStatus = 'All'; // All, Good, Warning, In Risk
  String _sortBy = 'Name'; // Name, Budget, Spent, Percentage

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
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
                      'Budget Management',
                      style: AppTextStyles.heading1,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage your categories and budget limits',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
                FilledButton.icon(
                  onPressed: () => _showAddCategoryDialog(),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Category'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Search, Filter, and Sort Bar
            _buildControlsBar(),

            const SizedBox(height: 24),

            // Categories List
            Expanded(
              child: StreamBuilder<List<Category>>(
                stream: widget.database.categoryDao.watchAllCategories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final categories = snapshot.data ?? [];
                  if (categories.isEmpty) {
                    return Center(
                      child: Text(
                        'No categories found.',
                        style: AppTextStyles.bodyLarge
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    );
                  }

                  // Apply filters and sorting
                  var filteredCategories = _applyFiltersAndSort(categories);

                  if (filteredCategories.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.filter_list_off,
                              size: 64, color: AppColors.textSecondary),
                          const SizedBox(height: 16),
                          Text(
                            'No categories match your filters',
                            style: AppTextStyles.bodyLarge
                                .copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredCategories.length,
                    itemBuilder: (context, index) {
                      final category = filteredCategories[index];

                      if (!_controllers.containsKey(category.id)) {
                        _controllers[category.id] = TextEditingController(
                          text: category.budget.toStringAsFixed(2),
                        );
                      }

                      return _buildCategoryCard(category);
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
// 3leh sir 3leh
  Widget _buildSummaryCard(
      String title, String amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            amount,
            style: AppTextStyles.heading2.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Category category) {
    final controller = _controllers[category.id]!;
    final iconData = _getIconFromCodePoint(category.iconCodePoint);
    final categoryColor = Color(category.color);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon, name, and edit button
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  iconData,
                  color: categoryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: AppTextStyles.heading3,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Monthly Budget: ${category.budget.toStringAsFixed(2)} DZD',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: () {
                      // Navigate to Add Expense page (index 1)
                      if (widget.onNavigate != null) {
                        widget.onNavigate!(1, categoryId: category.id);
                      }
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Expense'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => _showEditDialog(category, controller),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _deleteCategory(category),
                    icon: const Icon(Icons.delete_outline, size: 20),
                    color: AppColors.red,
                    tooltip: 'Delete Category',
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Progress bar
          _buildProgressBar(category),

          const SizedBox(height: 16),

          // Stats row
          _buildStatsRow(category),
        ],
      ),
    );
  }

  void _showEditDialog(Category category, TextEditingController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Edit Budget for ${category.name}',
            style: AppTextStyles.heading3),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          decoration: InputDecoration(
            labelText: 'Monthly Budget',
            prefixText: 'DZD ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          FilledButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              final value = double.tryParse(controller.text) ?? 0.0;
              if (value < 0) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Budget cannot be negative'),
                    backgroundColor: AppColors.red,
                  ),
                );
                return;
              }

              await widget.database.categoryDao
                  .updateCategoryBudget(category.id, value);

              if (mounted) {
                navigator.pop();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      'Updated ${category.name} budget to ${value.toStringAsFixed(2)} DZD',
                    ),
                    backgroundColor: AppColors.green,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Helper method to build progress bar with status color and percentage overlay
  Widget _buildProgressBar(Category category) {
    final percentage =
        category.budget > 0 ? (category.spent / category.budget) : 0.0;
    final statusColor = _getStatusColor(percentage);

    return Stack(
      children: [
        Container(
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage.clamp(0.0, 1.0),
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              minHeight: 24,
            ),
          ),
        ),
        Positioned.fill(
          child: Center(
            child: Text(
              '${(percentage * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                color: percentage > 0.5 ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper method to build stats row with status logic
  Widget _buildStatsRow(Category category) {
    final percentage =
        category.budget > 0 ? (category.spent / category.budget) : 0.0;
    final remaining = category.budget - category.spent;
    final status = _getStatusText(percentage);
    final statusColor = _getStatusColor(percentage);
    final statusIcon = _getStatusIcon(percentage);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Spent',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 4),
              Text(
                '${category.spent.toStringAsFixed(2)} DZD',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Remaining',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 4),
              Text(
                '${remaining.toStringAsFixed(2)} DZD',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Icon(
                statusIcon,
                color: statusColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                status,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Get status text based on percentage
  String _getStatusText(double percentage) {
    if (percentage < 0.5) return 'Good';
    if (percentage < 0.8) return 'Warning';
    return 'In Risk';
  }

  // Get status color based on percentage
  Color _getStatusColor(double percentage) {
    if (percentage < 0.5) return AppColors.green;
    if (percentage < 0.8) return AppColors.orange;
    return AppColors.red;
  }

  // Get status icon based on percentage
  IconData _getStatusIcon(double percentage) {
    if (percentage < 0.5) return Icons.check_circle;
    if (percentage < 0.8) return Icons.warning;
    return Icons.error;
  }

  // Build controls bar with search, filter, and sort
  Widget _buildControlsBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Search field
          Expanded(
            flex: 2,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _searchQuery.isNotEmpty
                      ? AppColors.primary
                      : AppColors.border,
                  width: 1,
                ),
              ),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search categories...',
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                  prefixIcon:
                      Icon(Icons.search, color: AppColors.textSecondary),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon:
                              Icon(Icons.clear, color: AppColors.textSecondary),
                          onPressed: () => setState(() => _searchQuery = ''),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Filter dropdown
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _filterStatus,
                  isExpanded: true,
                  icon: const Icon(Icons.filter_list),
                  dropdownColor: AppColors.surface,
                  items: ['All', 'Good', 'Warning', 'In Risk']
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Row(
                              children: [
                                Icon(
                                  _getFilterIcon(status),
                                  size: 18,
                                  color: _getFilterColor(status),
                                ),
                                const SizedBox(width: 8),
                                Text(status, style: AppTextStyles.bodyMedium),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _filterStatus = value!),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Sort dropdown
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _sortBy,
                  isExpanded: true,
                  icon: const Icon(Icons.sort),
                  dropdownColor: AppColors.surface,
                  items: ['Name', 'Budget', 'Spent', 'Percentage']
                      .map((sort) => DropdownMenuItem(
                            value: sort,
                            child: Text('Sort: $sort',
                                style: AppTextStyles.bodyMedium),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _sortBy = value!),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Apply filters and sorting to categories
  List<Category> _applyFiltersAndSort(List<Category> categories) {
    var filtered = categories.where((cat) {
      // Apply search filter
      if (_searchQuery.isNotEmpty &&
          !cat.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }

      // Apply status filter
      if (_filterStatus != 'All') {
        final percentage = cat.budget > 0 ? (cat.spent / cat.budget) : 0.0;
        final status = _getStatusText(percentage);
        if (status != _filterStatus) {
          return false;
        }
      }

      return true;
    }).toList();

    // Apply sorting
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'Budget':
          return b.budget.compareTo(a.budget);
        case 'Spent':
          return b.spent.compareTo(a.spent);
        case 'Percentage':
          final aPercentage = a.budget > 0 ? (a.spent / a.budget) : 0.0;
          final bPercentage = b.budget > 0 ? (b.spent / b.budget) : 0.0;
          return bPercentage.compareTo(aPercentage);
        case 'Name':
        default:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
    });

    return filtered;
  }

  // Get icon for filter status
  IconData _getFilterIcon(String status) {
    switch (status) {
      case 'Good':
        return Icons.check_circle;
      case 'Warning':
        return Icons.warning;
      case 'In Risk':
        return Icons.error;
      default:
        return Icons.filter_list;
    }
  }

  // Get color for filter status
  Color _getFilterColor(String status) {
    switch (status) {
      case 'Good':
        return AppColors.green;
      case 'Warning':
        return AppColors.orange;
      case 'In Risk':
        return AppColors.red;
      default:
        return AppColors.textSecondary;
    }
  }

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    final budgetController = TextEditingController();
    int selectedColor = AppColors.primary.value;
    String selectedIcon = '57744'; // Default icon code point

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Add New Category', style: AppTextStyles.heading3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Category Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: budgetController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: 'Monthly Budget',
                prefixText: 'DZD ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Color Selection
            StatefulBuilder(
              builder: (context, setState) {
                final List<Color> colors = [
                  AppColors.primary,
                  AppColors.accent,
                  AppColors.green,
                  AppColors.red,
                  AppColors.orange,
                  Colors.purple,
                  Colors.teal,
                  Colors.pink,
                ];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Color', style: AppTextStyles.label),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: colors.map((color) {
                        final isSelected = selectedColor == color.value;
                        return InkWell(
                          onTap: () => setState(() => selectedColor = color.value),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(color: AppColors.textPrimary, width: 2)
                                  : null,
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, color: Colors.white, size: 20)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            // Icon Selection
            StatefulBuilder(
              builder: (context, setState) {
                final List<IconData> icons = [
                  Icons.category,
                  Icons.home,
                  Icons.restaurant,
                  Icons.directions_car,
                  Icons.shopping_bag,
                  Icons.medical_services,
                  Icons.school,
                  Icons.flight,
                  Icons.sports_esports,
                  Icons.pets,
                ];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Icon', style: AppTextStyles.label),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: icons.map((icon) {
                        final isSelected = selectedIcon == icon.codePoint.toString();
                        return InkWell(
                          onTap: () => setState(() => selectedIcon = icon.codePoint.toString()),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withOpacity(0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: isSelected
                                  ? Border.all(color: AppColors.primary)
                                  : Border.all(color: AppColors.border),
                            ),
                            child: Icon(
                              icon,
                              color: isSelected ? AppColors.primary : AppColors.textSecondary,
                              size: 24,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          FilledButton(
            onPressed: () async {
              if (nameController.text.isEmpty) {
                return;
              }
              
              final budget = double.tryParse(budgetController.text) ?? 0.0;
              
              await widget.database.categoryDao.insertCategory(
                CategoriesCompanion.insert(
                  name: nameController.text,
                  budget: Value(budget),
                  color: selectedColor,
                  iconCodePoint: selectedIcon,
                ),
              );

              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Category added successfully'),
                    backgroundColor: AppColors.green,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Delete Category', style: AppTextStyles.heading3),
        content: Text(
          'Are you sure you want to delete "${category.name}"? This action cannot be undone.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          FilledButton(
            onPressed: () async {
              await widget.database.categoryDao.deleteCategory(category.id);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Category deleted'),
                    backgroundColor: AppColors.red,
                  ),
                );
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
