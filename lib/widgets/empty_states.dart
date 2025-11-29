import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';

/// Reusable empty state widget with illustration and message
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  final double iconSize;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.iconSize = 120,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Animated icon with subtle pulse
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.9, end: 1.0),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Icon(
                    icon,
                    size: iconSize,
                    color: colorScheme.primary.withOpacity(0.3),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),

            // Title
            Text(
              title,
              style: textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),

            // Message
            Text(
              message,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
            ),

            // Optional action button
            if (action != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty expenses list state
class EmptyExpensesState extends StatelessWidget {
  final VoidCallback? onAddExpense;

  const EmptyExpensesState({
    super.key,
    this.onAddExpense,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.receipt_long_outlined,
      title: 'No Expenses Yet',
      message: 'Start tracking your expenses by adding your first transaction.',
      action: onAddExpense != null
          ? FilledButton.icon(
              onPressed: onAddExpense,
              icon: const Icon(Icons.add),
              label: const Text('Add Expense'),
            )
          : null,
    );
  }
}

/// Empty budgets list state
class EmptyBudgetsState extends StatelessWidget {
  final VoidCallback? onAddBudget;

  const EmptyBudgetsState({
    super.key,
    this.onAddBudget,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.account_balance_wallet_outlined,
      title: 'No Budget Categories',
      message: 'Create budget categories to start managing your spending.',
      action: onAddBudget != null
          ? FilledButton.icon(
              onPressed: onAddBudget,
              icon: const Icon(Icons.add),
              label: const Text('Add Category'),
            )
          : null,
    );
  }
}

/// Empty search results state
class EmptySearchState extends StatelessWidget {
  final String searchQuery;
  final VoidCallback? onClear;

  const EmptySearchState({
    super.key,
    required this.searchQuery,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.search_off_outlined,
      title: 'No Results Found',
      message: 'No items match "$searchQuery". Try a different search term.',
      action: onClear != null
          ? TextButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.clear),
              label: const Text('Clear Search'),
            )
          : null,
    );
  }
}

/// Empty filtered results state
class EmptyFilteredState extends StatelessWidget {
  final VoidCallback? onClearFilters;

  const EmptyFilteredState({
    super.key,
    this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.filter_list_off_outlined,
      title: 'No Matching Items',
      message:
          'No items match the current filters. Try adjusting your filters.',
      action: onClearFilters != null
          ? TextButton.icon(
              onPressed: onClearFilters,
              icon: const Icon(Icons.clear),
              label: const Text('Clear Filters'),
            )
          : null,
    );
  }
}
