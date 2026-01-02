import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/app_config.dart';

/// Category pie chart widget for expense distribution
/// Simple visual representation using colored segments
class CategoryPieChart extends StatelessWidget {

  const CategoryPieChart({
    required this.categoryData, super.key,
  });
  final Map<String, double> categoryData;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (categoryData.isEmpty) {
      return _buildEmptyState(context);
    }

    final total = categoryData.values.fold(0.0, (sum, value) => sum + value);
    final sortedEntries = categoryData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.05),
            blurRadius: AppConfig.shadowBlurRadius,
            offset: const Offset(
                AppConfig.shadowOffsetX, AppConfig.shadowOffsetY,),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Expenses by Category',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: AppSpacing.xl),
          // Legend
          ...sortedEntries.take(5).map((entry) {
            final percentage = entry.value / total * 100;
            final color = _getCategoryColor(
                sortedEntries.indexOf(entry), colorScheme,);

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusXs),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: Center(
        child: Text(
          'No category data available',
          style: AppTextStyles.bodyMedium,
        ),
      ),
    );
  }

  Color _getCategoryColor(int index, ColorScheme colorScheme) {
    final colors = [
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
      Colors.orange,
      Colors.purple,
    ];
    return colors[index % colors.length];
  }
}
