import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';

/// A reusable budget progress bar widget showing spending vs budget
class BudgetProgressBar extends StatelessWidget {
  final Category category;

  const BudgetProgressBar({
    super.key,
    required this.category,
  });

  Color _getProgressColor() {
    final percentage =
        category.budget > 0 ? category.spent / category.budget : 0;

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
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
