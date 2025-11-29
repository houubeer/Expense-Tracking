import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/app_config.dart';
import 'package:expense_tracking_desktop_app/widgets/animations/animated_widgets.dart';

/// A configurable summary card widget for displaying summary information with an icon
/// Uses composition to allow customization of appearance and behavior
class SummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final Color color;
  final IconData icon;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final bool showShadow;
  final TextStyle? titleStyle;
  final TextStyle? amountStyle;
  final double? iconSize;
  final VoidCallback? onTap;

  const SummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.showShadow = true,
    this.titleStyle,
    this.amountStyle,
    this.iconSize,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cardContent = MergeSemantics(
      child: Container(
        padding: padding ?? const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: backgroundColor ?? colorScheme.surface,
          borderRadius:
              BorderRadius.circular(borderRadius ?? AppSpacing.radiusXl),
          border: Border.all(color: borderColor ?? colorScheme.outlineVariant),
          boxShadow: showShadow
              ? [
                  BoxShadow(
                    color: colorScheme.primary
                        .withValues(alpha: AppConfig.shadowOpacity),
                    blurRadius: AppConfig.shadowBlurRadiusLarge,
                    offset: const Offset(0, AppConfig.shadowOffsetYLarge),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.iconPadding),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: iconSize ?? AppSpacing.iconSm,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                  title,
                  style: titleStyle ??
                      AppTextStyles.bodyMedium.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            amount,
            style: amountStyle ??
                AppTextStyles.heading2.copyWith(color: colorScheme.onSurface),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return AnimatedHoverCard(
        scale: 1.015,
        onTap: onTap,
        child: cardContent,
      );
    }

    return cardContent;
  }
}