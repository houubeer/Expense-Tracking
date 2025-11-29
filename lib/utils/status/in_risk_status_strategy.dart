import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';
import 'package:expense_tracking_desktop_app/utils/status/i_budget_status_strategy.dart';

/// In Risk status: >= 80% budget used
class InRiskStatusStrategy implements IBudgetStatusStrategy {
  @override
  String get statusText => AppStrings.statusInRisk;

  @override
  Color get statusColor => AppColors.red;

  @override
  IconData get statusIcon => Icons.error;

  @override
  bool matches(double percentage) => percentage >= 0.8;
}
