import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/features/expenses/widgets/expense_list_header.dart';
import 'package:expense_tracking_desktop_app/features/expenses/widgets/expense_search_bar.dart';
import 'package:expense_tracking_desktop_app/features/expenses/widgets/expense_filters.dart';
import 'package:expense_tracking_desktop_app/features/expenses/widgets/expense_table.dart';
import 'package:expense_tracking_desktop_app/features/expenses/providers/expense_list_provider.dart';

class ExpensesListScreen extends ConsumerWidget {
  const ExpensesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final state = ref.watch(expenseListViewModelProvider);
    final viewModel = ref.read(expenseListViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ExpenseListHeader(),
            const SizedBox(height: AppSpacing.xxl),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: ExpenseSearchBar(
                    searchQuery: state.searchQuery,
                    onSearchChanged: viewModel.setSearchQuery,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  flex: 4,
                  child: ExpenseFilters(
                    selectedCategoryId: state.selectedCategoryId,
                    selectedDate: state.selectedDate,
                    onCategoryChanged: viewModel.setCategoryFilter,
                    onDateChanged: viewModel.setDateFilter,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Expanded(
              child: _buildContent(context, state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ExpenseListState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: ${state.error}'),
          ],
        ),
      );
    }

    return ExpenseTable(expenses: state.filteredExpenses);
  }
}
