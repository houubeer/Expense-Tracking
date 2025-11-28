import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/features/budget/repositories/category_repository.dart';
import 'package:expense_tracking_desktop_app/features/budget/widgets/edit_category_dialog.dart';
import 'package:expense_tracking_desktop_app/features/budget/widgets/budget_category_card.dart';
import 'package:expense_tracking_desktop_app/features/budget/widgets/budget_controls_bar.dart';
import 'package:expense_tracking_desktop_app/features/budget/view_models/budget_view_model.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';
import 'package:expense_tracking_desktop_app/constants/category_options.dart';
import 'package:drift/drift.dart' hide Column;

class BudgetSettingScreen extends ConsumerStatefulWidget {
  final CategoryRepository categoryRepository;

  const BudgetSettingScreen({required this.categoryRepository, super.key});

  @override
  ConsumerState<BudgetSettingScreen> createState() =>
      _BudgetSettingScreenState();
}

class _BudgetSettingScreenState extends ConsumerState<BudgetSettingScreen> {
  final Map<int, TextEditingController> _controllers = {};

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
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
            const BudgetControlsBar(),

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

                  // Apply filters and sorting using ViewModel
                  final filter = ref.watch(budgetFilterProvider);
                  final viewModel = ref.read(budgetViewModelProvider);
                  final filteredCategories =
                      viewModel.applyFiltersAndSort(categories, filter);

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
                      _controllers.putIfAbsent(
                        category.id,
                        () => TextEditingController(
                          text: category.budget.toStringAsFixed(2),
                        ),
                      );

                      return BudgetCategoryCard(
                        category: category,
                        onEdit: () => _showEditDialog(
                          category,
                          _controllers[category.id]!,
                        ),
                        onDelete: () => _deleteCategory(category),
                      );
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

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    final budgetController = TextEditingController();
    int selectedColor = CategoryColors.colors[0].value;
    String selectedIcon = CategoryIcons.icons[0].codePoint.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Add New Category', style: AppTextStyles.heading3),
        content: SingleChildScrollView(
          child: Column(
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
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppStrings.labelColor, style: AppTextStyles.label),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: CategoryColors.colors.map((color) {
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
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppStrings.labelIcon, style: AppTextStyles.label),
                      const SizedBox(height: AppSpacing.sm),
                      SizedBox(
                        height: 200,
                        child: SingleChildScrollView(
                          child: Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: CategoryIcons.icons.map((icon) {
                              final isSelected =
                                  selectedIcon == icon.codePoint.toString();
                              return InkWell(
                                onTap: () => setState(() =>
                                    selectedIcon = icon.codePoint.toString()),
                                borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusSm),
                                child: Container(
                                  padding: const EdgeInsets.all(AppSpacing.sm),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary.withOpacity(0.1)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusSm),
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
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
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
