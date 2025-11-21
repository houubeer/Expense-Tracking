import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';

class BudgetSettingScreen extends StatefulWidget {
  final AppDatabase database;
  final Function(int)? onNavigate;

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
      backgroundColor: AppColors.grey200,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Budget Management',
              style: AppTextStyles.heading1,
            ),
            const SizedBox(height: 8),
            const Text(
              'Track your spending against monthly budget limits',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 32),

            // Budget Summary Cards
            StreamBuilder<List<Category>>(
              stream: widget.database.categoryDao.watchAllCategories(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox();
                }

                final categories = snapshot.data!;
                final totalBudget = categories.fold<double>(
                  0.0,
                  (sum, cat) => sum + cat.budget,
                );
                final totalSpent = categories.fold<double>(
                  0.0,
                  (sum, cat) => sum + cat.spent,
                );
                final remaining = totalBudget - totalSpent;

                return Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Total Monthly Budget',
                        '${totalBudget.toStringAsFixed(2)} DZD',
                        AppColors.primaryBlue, // Match sidebar color
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildSummaryCard(
                        'Total Spent This Month',
                        '${totalSpent.toStringAsFixed(2)} DZD',
                        const Color(0xFF7C3AED), // Clean purple
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildSummaryCard(
                        'Remaining Budget',
                        '${remaining.toStringAsFixed(2)} DZD',
                        const Color(0xFF059669), // Clean emerald green
                      ),
                    ),
                  ],
                );
              },
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
                    return const Center(
                      child: Text('No categories found.'),
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
                              size: 64, color: AppColors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'No categories match your filters',
                            style: AppTextStyles.bodyLarge
                                .copyWith(color: AppColors.grey),
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

  Widget _buildSummaryCard(String title, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
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
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.08),
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
                        widget.onNavigate!(1);
                      }
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Expense'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => _showEditDialog(category, controller),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Progress bar (removed "Progress" label)
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
        title: Text('Edit Budget for ${category.name}'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          decoration: const InputDecoration(
            labelText: 'Monthly Budget',
            prefixText: 'DZD ',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final value = double.tryParse(controller.text) ?? 0.0;
              if (value < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Budget cannot be negative'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              await widget.database.categoryDao
                  .updateCategoryBudget(category.id, value);

              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Updated ${category.name} budget to ${value.toStringAsFixed(2)} DZD',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
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
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.grey300,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage.clamp(0.0, 1.0),
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              minHeight: 32,
            ),
          ),
        ),
        Positioned.fill(
          child: Center(
            child: Text(
              '${(percentage * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                color: percentage > 0.3 ? Colors.white : AppColors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
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
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${category.spent.toStringAsFixed(2)} DZD',
                style: AppTextStyles.bodyLarge,
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
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${remaining.toStringAsFixed(2)} DZD',
                style: AppTextStyles.bodyLarge,
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
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                status,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: statusColor,
                ),
              ),
            ],
          ),
        ),
        Text(
          '${(percentage * 100).toStringAsFixed(1)}%',
          style: AppTextStyles.bodyLarge.copyWith(
            color: statusColor,
            fontWeight: FontWeight.w600,
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
    if (percentage < 0.5) return const Color(0xFF10B981); // Green
    if (percentage < 0.8) return const Color(0xFFF59E0B); // Yellow
    return const Color(0xFFEF4444); // Red
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
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
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
                color: AppColors.grey200,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _searchQuery.isNotEmpty
                      ? AppColors.primaryBlue
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search categories...',
                  hintStyle: TextStyle(color: AppColors.grey),
                  prefixIcon: Icon(Icons.search, color: AppColors.grey),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: AppColors.grey),
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
                color: AppColors.grey200,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.grey300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _filterStatus,
                  isExpanded: true,
                  icon: const Icon(Icons.filter_list),
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
                                Text(status),
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
                color: AppColors.grey200,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.grey300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _sortBy,
                  isExpanded: true,
                  icon: const Icon(Icons.sort),
                  items: ['Name', 'Budget', 'Spent', 'Percentage']
                      .map((sort) => DropdownMenuItem(
                            value: sort,
                            child: Text('Sort: $sort'),
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
        return const Color(0xFF10B981);
      case 'Warning':
        return const Color(0xFFF59E0B);
      case 'In Risk':
        return const Color(0xFFEF4444);
      default:
        return AppColors.grey;
    }
  }
}
