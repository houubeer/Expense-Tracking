import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/utils/budget_status_calculator.dart';

/// A configurable budget progress bar widget showing spending vs budget
/// Uses composition and dependency injection for flexibility
class BudgetProgressBar extends StatelessWidget {
  final Category category;
  final BudgetStatusCalculator? statusCalculator;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final bool showPercentage;

  const BudgetProgressBar({
    super.key,
    required this.category,
    this.statusCalculator,
    this.height,
    this.borderRadius,
    this.backgroundColor,
    this.showPercentage = false,
  });

  Color _getProgressColor() {
    final percentage =
        category.budget > 0 ? category.spent / category.budget : 0.0;

    // Use injected calculator if provided, otherwise use default logic
    if (statusCalculator != null) {
      return statusCalculator!.getStatusColorWithConfig(percentage);
    }

    // Fallback to hardcoded logic for backward compatibility
    if (percentage >= 1.0) return AppColors.red;
    if (percentage >= 0.9) return AppColors.orange;
    if (percentage >= 0.75) return AppColors.purple;
    return AppColors.accent;
  }

  @override
  Widget build(BuildContext context) {
    final percentage = category.budget > 0
        ? (category.spent / category.budget).clamp(0.0, 1.0)
        : 0.0;
    final progressColor = _getProgressColor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius:
              borderRadius ?? BorderRadius.circular(AppSpacing.radiusSm),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: backgroundColor ?? AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            minHeight: height ?? AppSpacing.sm,
          ),
        ),
        if (showPercentage) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${(percentage * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 12,
              color: progressColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
