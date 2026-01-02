import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/app_config.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';

/// Monthly bar chart widget for expense trends
/// Simple bar chart visualization without external dependencies
class MonthlyBarChart extends StatelessWidget {

  const MonthlyBarChart({
    required this.monthlyData, super.key,
  });
  final Map<String, double> monthlyData;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (monthlyData.isEmpty) {
      return _buildEmptyState(context);
    }

    final maxValue =
        monthlyData.values.fold(0.0, (max, value) => value > max ? value : max);

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
            'Monthly Expense Trends',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: monthlyData.entries.map((entry) {
                final heightPercentage = entry.value / maxValue;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Value label
                        Text(
                          '${(entry.value / 1000).toStringAsFixed(0)}k',
                          style: AppTextStyles.caption,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        // Bar
                        Container(
                          height: 150 * heightPercentage,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(AppSpacing.radiusSm),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        // Month label
                        Text(
                          entry.key,
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Y-axis label
          Text(
            'Amount (${AppStrings.currency})',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: Center(
        child: Text(
          'No monthly data available',
          style: AppTextStyles.bodyMedium,
        ),
      ),
    );
  }
}
