import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';

/// Page header widget matching BudgetScreenHeader style
/// Displays title, subtitle, and optional action button
class PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? actionButton;

  const PageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.actionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.heading1,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              subtitle,
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
        if (actionButton != null) actionButton!,
      ],
    );
  }
}
