import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';

class ExpenseSearchBar extends StatelessWidget {

  const ExpenseSearchBar({
    required this.searchQuery, required this.onSearchChanged, super.key,
  });
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(
          color: searchQuery.isNotEmpty
              ? colorScheme.primary
              : colorScheme.outlineVariant,
        ),
      ),
      child: TextField(
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          hintText: AppStrings.hintSearchExpenses,
          hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
          prefixIcon: Icon(Icons.search,
              color: colorScheme.onSurfaceVariant, semanticLabel: 'Search',),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear,
                      color: colorScheme.onSurfaceVariant,
                      semanticLabel: 'Clear search',),
                  onPressed: () => onSearchChanged(''),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
