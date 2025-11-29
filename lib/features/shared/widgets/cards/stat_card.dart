import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/app_config.dart';

/// A configurable statistics card widget for displaying metrics with trends
/// Uses composition over hardcoded values for maximum flexibility
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String trend;
  final IconData icon;
  final Color color;
  final double? width;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final bool showShadow;
  final bool showTrend;
  final TextStyle? titleStyle;
  final TextStyle? valueStyle;
  final TextStyle? trendStyle;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.trend,
    required this.icon,
    required this.color,
    this.width,
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.showShadow = true,
    this.showTrend = true,
    this.titleStyle,
    this.valueStyle,
    this.trendStyle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return MergeSemantics(
        child: Container(
      width: width,
      padding: padding ?? const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
        borderRadius:
            BorderRadius.circular(borderRadius ?? AppSpacing.radiusLg),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.iconPadding),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(icon, color: color, size: AppSpacing.iconSm),
              ),
              if (showTrend)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: trend.startsWith('+')
                        ? colorScheme.tertiary.withValues(alpha: 0.1)
                        : colorScheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                  child: Text(
                    trend,
                    style: trendStyle ??
                        AppTextStyles.caption.copyWith(
                          color: trend.startsWith('+')
                              ? colorScheme.tertiary
                              : colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(value, style: valueStyle ?? AppTextStyles.heading2),
          const SizedBox(height: AppSpacing.xs),
          Text(title, style: titleStyle ?? AppTextStyles.bodyMedium),
        ],
      ),
    ));
  }
}
