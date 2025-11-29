import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';
import 'package:expense_tracking_desktop_app/utils/status/i_budget_status_strategy.dart';

/// Good status: < 50% budget used
class GoodStatusStrategy implements IBudgetStatusStrategy {
  @override
  String get statusText => AppStrings.statusGood;

  @override
  Color get statusColor => const Color(0xFF10B981); // Emerald green

  @override
  IconData get statusIcon => Icons.check_circle;

  @override
  bool matches(double percentage) => percentage < 0.5;
}
