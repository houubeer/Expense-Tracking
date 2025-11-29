import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/features/budget/repositories/i_category_repository.dart';
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

import 'package:expense_tracking_desktop_app/widgets/shimmer_loader.dart';

class BudgetSettingScreen extends ConsumerStatefulWidget {
  final ICategoryRepository categoryRepository;

  const BudgetSettingScreen({
    required this.categoryRepository,
    super.key,
  });

  @override
  ConsumerState<BudgetSettingScreen> createState() =>
      _BudgetSettingScreenState();
}

class _BudgetSettingScreenState extends ConsumerState<BudgetSettingScreen> {
  late final BudgetViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel =
        BudgetViewModel(widget.categoryRepository, widget.categoryRepository);
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
          return ShimmerLoaders.list(
            context,
            itemBuilder: ShimmerLoaders.budgetCard,
            itemCount: 3,
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
          _showSuccessMessage(AppStrings.msgCategoryAdded);
        },
      ),
    );
  }

  void _handleEditCategory(Category category) {
    showDialog(
      context: context,
      builder: (context) => EditCategoryDialog(
        categoryRepository: widget.categoryRepository,
        category: category,
        budgetController: _viewModel.getController(category),
      ),
    );
  }

  void _handleDeleteCategory(Category category) {
    showDialog(
      context: context,
      builder: (context) => DeleteCategoryDialog(
        category: category,
        onConfirm: () async {
          await _viewModel.deleteCategory(category.id);
          _showSuccessMessage(AppStrings.msgCategoryDeleted);
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
}
