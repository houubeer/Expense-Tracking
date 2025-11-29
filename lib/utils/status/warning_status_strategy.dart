import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';
import 'package:expense_tracking_desktop_app/utils/status/i_budget_status_strategy.dart';

/// Warning status: 50-80% budget used
class WarningStatusStrategy implements IBudgetStatusStrategy {
  @override
  String get statusText => AppStrings.statusWarning;

  @override
  Color get statusColor => AppColors.orange;

  @override
  IconData get statusIcon => Icons.warning;

  @override
  bool matches(double percentage) => percentage >= 0.5 && percentage < 0.8;
}
