import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:fl_chart/fl_chart.dart';

/// Pie chart widget for expense category breakdown
class ExpenseCategoryPieChart extends StatelessWidget {

  const ExpenseCategoryPieChart({
    required this.categoryData, super.key,
  });
  final Map<String, double> categoryData;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (categoryData.isEmpty) {
      return Center(
        child: Text(
          'No expense data available',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final total = categoryData.values.fold(0.0, (sum, value) => sum + value);
    final colors = _getCategoryColors(colorScheme);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Expense by Category',
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: Row(
              children: [
                // Pie Chart
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      sections: _buildSections(categoryData, total, colors),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xl),
                // Legend
                Expanded(
                  child: _buildLegend(
                      categoryData, total, colors, textTheme, colorScheme,),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections(
    Map<String, double> data,
    double total,
    List<Color> colors,
  ) {
    final entries = data.entries.toList();
    return List.generate(entries.length, (index) {
      final entry = entries[index];
      final percentage = (entry.value / total) * 100;
      return PieChartSectionData(
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        color: colors[index % colors.length],
        radius: 30,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }

  Widget _buildLegend(
    Map<String, double> data,
    double total,
    List<Color> colors,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    final entries = data.entries.toList();
    return ListView.separated(
      shrinkWrap: true,
      itemCount: entries.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final entry = entries[index];
        final percentage = (entry.value / total) * 100;
        return Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: colors[index % colors.length],
                borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '\$${entry.value.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  List<Color> _getCategoryColors(ColorScheme colorScheme) {
    return [
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
      colorScheme.error,
      colorScheme.primaryContainer,
      colorScheme.secondaryContainer,
    ];
  }
}
