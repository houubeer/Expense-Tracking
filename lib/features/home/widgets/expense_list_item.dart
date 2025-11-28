import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';

/// A reusable expense list item widget
class ExpenseListItem extends StatelessWidget {
  final String title;
  final String category;
  final String date;
  final double amount;
  final Color iconColor;

  const ExpenseListItem({
    super.key,
    required this.title,
    required this.category,
    required this.date,
    required this.amount,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.receipt_long_rounded, color: iconColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: AppTextStyles.bodyLarge
                      .copyWith(fontWeight: FontWeight.w600)),
              Text("$category • $date", style: AppTextStyles.caption),
            ],
          ),
        ),
        Text(
          "-${amount.toStringAsFixed(2)}",
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
