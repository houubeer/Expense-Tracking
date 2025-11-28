import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/features/budget/repositories/category_repository.dart';
import 'package:expense_tracking_desktop_app/features/budget/widgets/edit_category_dialog.dart';
import 'package:expense_tracking_desktop_app/utils/budget_status_calculator.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';
import 'package:expense_tracking_desktop_app/constants/app_config.dart';
import 'package:expense_tracking_desktop_app/constants/app_routes.dart';
import 'package:drift/drift.dart' hide Column;

class BudgetSettingScreen extends StatefulWidget {
  final CategoryRepository categoryRepository;

  const BudgetSettingScreen({required this.categoryRepository, super.key});

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
        padding: const EdgeInsets.all(AppSpacing.xxxl),
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
                      AppStrings.titleBudgetManagement,
                      style: AppTextStyles.heading1,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      AppStrings.descManageBudgets,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
                FilledButton.icon(
                  onPressed: () => _showAddCategoryDialog(),
                  icon: const Icon(Icons.add, size: AppSpacing.iconXs),
                  label: Text(AppStrings.btnAddCategory),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl - 4,
                      vertical: AppSpacing.lg,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Search, Filter, and Sort Bar
            _buildControlsBar(),

            const SizedBox(height: AppSpacing.xl),

            // Categories List
            Expanded(
              child: StreamBuilder<List<Category>>(
                stream: widget.categoryRepository.watchAllCategories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final categories = snapshot.data ?? [];
                  if (categories.isEmpty) {
                    return Center(
                      child: Text(
                        AppStrings.descNoCategoriesFound,
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
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            AppStrings.descNoMatchingCategories,
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

  Widget _buildCategoryCard(Category category) {
    final controller = _controllers[category.id]!;
    final iconData = _getIconFromCodePoint(category.iconCodePoint);
    final categoryColor = Color(category.color);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: AppConfig.shadowBlurRadius,
            offset: Offset(AppConfig.shadowOffsetX, AppConfig.shadowOffsetY),
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
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: Icon(
                  iconData,
                  color: categoryColor,
                  size: AppSpacing.iconLg,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: AppTextStyles.heading3,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${AppStrings.labelMonthlyBudget}: ${category.budget.toStringAsFixed(2)} ${AppStrings.currency}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: () => context.go(AppRoutes.addExpense),
                    icon: const Icon(Icons.add, size: AppSpacing.iconXs),
                    label: Text(AppStrings.btnAddExpense),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: () => _showEditDialog(category, controller),
                    icon: const Icon(Icons.edit, size: AppSpacing.iconXs),
                    label: Text(AppStrings.btnEdit),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton(
                    onPressed: () => _deleteCategory(category),
                    icon: const Icon(Icons.delete_outline,
                        size: AppSpacing.iconSm),
                    color: AppColors.red,
                    tooltip: 'Delete Category',
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // Progress bar
          _buildProgressBar(category),

          const SizedBox(height: AppSpacing.lg),

          // Stats row
          _buildStatsRow(category),
        ],
      ),
    );
  }

  void _showEditDialog(Category category, TextEditingController controller) {
    showDialog(
      context: context,
      builder: (context) => EditCategoryDialog(
        categoryRepository: widget.categoryRepository,
        category: category,
        budgetController: controller,
      ),
    );
  }

  // Helper method to build progress bar with status color and percentage overlay
  Widget _buildProgressBar(Category category) {
    final percentage = BudgetStatusCalculator.calculatePercentage(
        category.spent, category.budget);
    final statusColor = BudgetStatusCalculator.getStatusColor(percentage);

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
              style: AppTextStyles.progressPercentage.copyWith(
                color: percentage > 0.5 ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper method to build stats row with status logic
  Widget _buildStatsRow(Category category) {
    final percentage = BudgetStatusCalculator.calculatePercentage(
        category.spent, category.budget);
    final remaining = category.budget - category.spent;
    final status = BudgetStatusCalculator.getStatusText(percentage);
    final statusColor = BudgetStatusCalculator.getStatusColor(percentage);
    final statusIcon = BudgetStatusCalculator.getStatusIcon(percentage);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.labelSpent,
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${category.spent.toStringAsFixed(2)} ${AppStrings.currency}',
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
                AppStrings.labelRemaining,
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${remaining.toStringAsFixed(2)} ${AppStrings.currency}',
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
                size: AppSpacing.iconXs,
              ),
              const SizedBox(width: AppSpacing.sm),
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

  // Build controls bar with search, filter, and sort
  Widget _buildControlsBar() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl - 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: AppConfig.shadowBlurRadiusMd,
            offset: Offset(AppConfig.shadowOffsetX, AppConfig.shadowOffsetY),
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
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
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
                  hintText: AppStrings.hintSearchCategories,
                  hintStyle: AppTextStyles.bodyMedium,
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
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl - 4, vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          // Filter dropdown
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _filterStatus,
                  isExpanded: true,
                  icon: const Icon(Icons.filter_list),
                  dropdownColor: AppColors.surface,
                  items: [
                    AppStrings.filterAll,
                    AppStrings.statusGood,
                    AppStrings.statusWarning,
                    AppStrings.statusInRisk
                  ]
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Row(
                              children: [
                                Icon(
                                  BudgetStatusCalculator.getFilterIcon(status),
                                  size: AppSpacing.iconXs,
                                  color:
                                      BudgetStatusCalculator.getFilterColor(status),
                                ),
                                const SizedBox(width: AppSpacing.sm),
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
          const SizedBox(width: AppSpacing.lg),
          // Sort dropdown
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _sortBy,
                  isExpanded: true,
                  icon: const Icon(Icons.sort),
                  dropdownColor: AppColors.surface,
                  items: [
                    AppStrings.filterSortByName,
                    AppStrings.filterSortByBudget,
                    AppStrings.filterSortBySpent,
                    AppStrings.filterSortByPercentage
                  ]
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
        final percentage = BudgetStatusCalculator.calculatePercentage(
            cat.spent, cat.budget);
        final status = BudgetStatusCalculator.getStatusText(percentage);
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
          final aPercentage = BudgetStatusCalculator.calculatePercentage(
              a.spent, a.budget);
          final bPercentage = BudgetStatusCalculator.calculatePercentage(
              b.spent, b.budget);
          return bPercentage.compareTo(aPercentage);
        case 'Name':
        default:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
    });

    return filtered;
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
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
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
            const SizedBox(height: AppSpacing.lg),
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
                    Text(AppStrings.labelColor, style: AppTextStyles.label),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: colors.map((color) {
                        final isSelected = selectedColor == color.value;
                        return InkWell(
                          onTap: () =>
                              setState(() => selectedColor = color.value),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusXl + 4),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(
                                      color: AppColors.textPrimary, width: 2)
                                  : null,
                            ),
                            child: isSelected
                                ? const Icon(Icons.check,
                                    color: Colors.white,
                                    size: AppSpacing.iconXs + 2)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
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
                    Text(AppStrings.labelIcon, style: AppTextStyles.label),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: icons.map((icon) {
                        final isSelected =
                            selectedIcon == icon.codePoint.toString();
                        return InkWell(
                          onTap: () => setState(
                              () => selectedIcon = icon.codePoint.toString()),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusSm),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withOpacity(0.1)
                                  : Colors.transparent,
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusSm),
                              border: isSelected
                                  ? Border.all(color: AppColors.primary)
                                  : Border.all(color: AppColors.border),
                            ),
                            child: Icon(
                              icon,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              size: AppSpacing.iconMd,
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
            child: Text(AppStrings.btnCancel, style: AppTextStyles.bodyMedium),
          ),
          FilledButton(
            onPressed: () async {
              if (nameController.text.isEmpty) {
                return;
              }

              final budget = double.tryParse(budgetController.text) ?? 0.0;

              await widget.categoryRepository.insertCategory(
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
                    content: Text(AppStrings.msgCategoryAdded),
                    backgroundColor: AppColors.green,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text(AppStrings.btnAdd),
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
        title:
            Text(AppStrings.titleDeleteCategory, style: AppTextStyles.heading3),
        content: Text(
          AppStrings.descDeleteCategory.replaceAll('{name}', category.name),
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.btnCancel, style: AppTextStyles.bodyMedium),
          ),
          FilledButton(
            onPressed: () async {
              await widget.categoryRepository.deleteCategory(category.id);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(AppStrings.msgCategoryDeleted),
                    backgroundColor: AppColors.red,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.red),
            child: const Text(AppStrings.btnDelete),
          ),
        ],
      ),
    );
  }
}
