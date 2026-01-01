import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/features/budget/view_models/budget_view_model.dart';
import 'package:expense_tracking_desktop_app/features/budget/widgets/budget_screen_header.dart';
import 'package:expense_tracking_desktop_app/features/budget/widgets/budget_empty_states.dart';
import 'package:expense_tracking_desktop_app/features/budget/widgets/budget_controls_bar.dart';
import 'package:expense_tracking_desktop_app/features/budget/widgets/budget_category_card.dart';
import 'package:expense_tracking_desktop_app/features/budget/widgets/add_category_dialog.dart';
import 'package:expense_tracking_desktop_app/features/budget/widgets/edit_category_dialog.dart';
import 'package:expense_tracking_desktop_app/features/budget/widgets/delete_category_dialog.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';
import 'package:expense_tracking_desktop_app/widgets/animations/staggered_list_animation.dart';
import 'package:expense_tracking_desktop_app/widgets/animations/animated_widgets.dart';
import 'package:expense_tracking_desktop_app/providers/app_providers.dart';

class BudgetSettingScreen extends ConsumerStatefulWidget {
  const BudgetSettingScreen({
    super.key,
  });

  @override
  ConsumerState<BudgetSettingScreen> createState() =>
      _BudgetSettingScreenState();
}

class _BudgetSettingScreenState extends ConsumerState<BudgetSettingScreen> {
  late final BudgetViewModel _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final categoryRepository = ref.read(categoryRepositoryProvider);
    final errorReporting = ref.read(errorReportingServiceProvider);
    _viewModel =
        BudgetViewModel(categoryRepository, categoryRepository, errorReporting);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BudgetScreenHeader(onAddPressed: _handleAddCategory),
            const SizedBox(height: AppSpacing.xxl),
            const BudgetControlsBar(),
            const SizedBox(height: AppSpacing.xl),
            Expanded(child: _buildCategoriesList()),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesList() {
    final filter = ref.watch(budgetFilterProvider);

    return StreamBuilder<List<Category>>(
      stream: _viewModel.watchFilteredCategories(filter),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: ShimmerLoading(
              child: _buildShimmerPlaceholder(),
            ),
          );
        }

        final categories = snapshot.data ?? [];

        if (categories.isEmpty && filter.searchQuery.isEmpty) {
          return const BudgetEmptyState();
        }

        if (categories.isEmpty) {
          return const BudgetNoMatchesState();
        }

        return _buildCategoryList(categories);
      },
    );
  }

  Widget _buildCategoryList(List<Category> categories) {
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];

        return FadeInListItem(
          index: index,
          child: BudgetCategoryCard(
            category: category,
            onEdit: () => _handleEditCategory(category),
            onDelete: () => _handleDeleteCategory(category),
          ),
        );
      },
    );
  }

  void _handleAddCategory() {
    showDialog<void>(
      context: context,
      builder: (context) => AddCategoryDialog(
        onAdd: (name, budget, color, iconCodePoint) async {
          try {
            await _viewModel.addCategory(
              name: name,
              budget: budget,
              color: color,
              iconCodePoint: iconCodePoint,
            );
            _showSuccessMessage(AppStrings.msgCategoryAdded);
          } catch (e) {
            if (mounted) {
              _showErrorMessage('Failed to add category: ${e.toString()}');
            }
          }
        },
      ),
    );
  }

  void _handleEditCategory(Category category) {
    final categoryRepository = ref.read(categoryRepositoryProvider);
    showDialog<void>(
      context: context,
      builder: (context) => EditCategoryDialog(
        categoryRepository: categoryRepository,
        category: category,
        budgetController: _viewModel.getController(category),
      ),
    );
  }

  void _handleDeleteCategory(Category category) {
    showDialog<void>(
      context: context,
      builder: (context) => DeleteCategoryDialog(
        category: category,
        onConfirm: () async {
          try {
            await _viewModel.deleteCategory(category.id);
            _showSuccessMessage(AppStrings.msgCategoryDeleted);
          } catch (e) {
            if (mounted) {
              _showErrorMessage('Failed to delete category: ${e.toString()}');
            }
          }
        },
      ),
    );
  }

  void _showSuccessMessage(String message) {
    if (!mounted) return;
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: colorScheme.tertiary),
    );
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: colorScheme.error),
    );
  }

  Widget _buildShimmerPlaceholder() {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        height: 150,
      ),
    );
  }
}
