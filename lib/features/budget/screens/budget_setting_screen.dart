import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/features/budget/repositories/category_repository.dart';
import 'package:expense_tracking_desktop_app/features/budget/widgets/edit_category_dialog.dart';
import 'package:expense_tracking_desktop_app/features/budget/widgets/add_category_dialog.dart';
import 'package:expense_tracking_desktop_app/features/budget/widgets/delete_category_dialog.dart';
import 'package:expense_tracking_desktop_app/features/budget/widgets/budget_category_card.dart';
import 'package:expense_tracking_desktop_app/features/budget/widgets/budget_controls_bar.dart';
import 'package:expense_tracking_desktop_app/features/budget/view_models/budget_view_model.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';

/// Budget Setting Screen - Displays and manages budget categories
/// 
/// Responsibilities (SRP-compliant):
/// - Render UI layout
/// - React to ViewModel state
/// - Delegate actions to ViewModel
class BudgetSettingScreen extends ConsumerStatefulWidget {
  final CategoryRepository categoryRepository;

  const BudgetSettingScreen({required this.categoryRepository, super.key});

  @override
  ConsumerState<BudgetSettingScreen> createState() =>
      _BudgetSettingScreenState();
}

class _BudgetSettingScreenState extends ConsumerState<BudgetSettingScreen> {
  late final BudgetViewModel _viewModel;
  final Map<int, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _viewModel = BudgetViewModel(widget.categoryRepository);
  }

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
            _buildHeader(),
            const SizedBox(height: AppSpacing.xxl),
            const BudgetControlsBar(),
            const SizedBox(height: AppSpacing.xl),
            Expanded(child: _buildCategoriesList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
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
          onPressed: _showAddCategoryDialog,
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
    );
  }

  Widget _buildCategoriesList() {
    return StreamBuilder<List<Category>>(
      stream: widget.categoryRepository.watchAllCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final categories = snapshot.data ?? [];

        if (categories.isEmpty) {
          return _buildEmptyState();
        }

        final filter = ref.watch(budgetFilterProvider);
        final filteredCategories =
            _viewModel.applyFiltersAndSort(categories, filter);

        if (filteredCategories.isEmpty) {
          return _buildNoMatchesState();
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
              onEdit: () => _showEditDialog(category),
              onDelete: () => _showDeleteDialog(category),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        AppStrings.descNoCategoriesFound,
        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildNoMatchesState() {
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

  // Dialog methods - delegate logic to ViewModel
  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AddCategoryDialog(
        onAdd: (name, budget, color, iconCodePoint) async {
          await _viewModel.addCategory(
            name: name,
            budget: budget,
            color: color,
            iconCodePoint: iconCodePoint,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(AppStrings.msgCategoryAdded),
                backgroundColor: AppColors.green,
              ),
            );
          }
        },
      ),
    );
  }

  void _showEditDialog(Category category) {
    showDialog(
      context: context,
      builder: (context) => EditCategoryDialog(
        categoryRepository: widget.categoryRepository,
        category: category,
        budgetController: _controllers[category.id]!,
      ),
    );
  }

  void _showDeleteDialog(Category category) {
    showDialog(
      context: context,
      builder: (context) => DeleteCategoryDialog(
        category: category,
        onConfirm: () async {
          await _viewModel.deleteCategory(category.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(AppStrings.msgCategoryDeleted),
                backgroundColor: AppColors.red,
              ),
            );
          }
        },
      ),
    );
  }
}
