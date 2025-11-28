import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/utils/status/i_budget_status_strategy.dart';

/// Configurable budget status strategy with customizable thresholds
/// Allows fine-tuning of status calculation without creating new classes
class ConfigurableBudgetStatusStrategy implements IBudgetStatusStrategy {
  final String _statusText;
  final Color _statusColor;
  final IconData _statusIcon;
  final double _minThreshold;
  final double _maxThreshold;

  const ConfigurableBudgetStatusStrategy({
    required String statusText,
    required Color statusColor,
    required IconData statusIcon,
    required double minThreshold,
    double? maxThreshold,
  })  : _statusText = statusText,
        _statusColor = statusColor,
        _statusIcon = statusIcon,
        _minThreshold = minThreshold,
        _maxThreshold = maxThreshold ?? double.infinity;

  @override
  String get statusText => _statusText;

  @override
  Color get statusColor => _statusColor;

  @override
  IconData get statusIcon => _statusIcon;

  @override
  bool matches(double percentage) {
    return percentage >= _minThreshold && percentage < _maxThreshold;
  }

  /// Create a Good status strategy with custom threshold
  factory ConfigurableBudgetStatusStrategy.good({
    required String statusText,
    required Color statusColor,
    required IconData statusIcon,
    double maxThreshold = 0.5,
  }) {
    return ConfigurableBudgetStatusStrategy(
      statusText: statusText,
      statusColor: statusColor,
      statusIcon: statusIcon,
      minThreshold: 0.0,
      maxThreshold: maxThreshold,
    );
  }

  /// Create a Warning status strategy with custom thresholds
  factory ConfigurableBudgetStatusStrategy.warning({
    required String statusText,
    required Color statusColor,
    required IconData statusIcon,
    double minThreshold = 0.5,
    double maxThreshold = 0.8,
  }) {
    return ConfigurableBudgetStatusStrategy(
      statusText: statusText,
      statusColor: statusColor,
      statusIcon: statusIcon,
      minThreshold: minThreshold,
      maxThreshold: maxThreshold,
    );
  }

  /// Create an At Risk status strategy with custom threshold
  factory ConfigurableBudgetStatusStrategy.atRisk({
    required String statusText,
    required Color statusColor,
    required IconData statusIcon,
    double minThreshold = 0.8,
  }) {
    return ConfigurableBudgetStatusStrategy(
      statusText: statusText,
      statusColor: statusColor,
      statusIcon: statusIcon,
      minThreshold: minThreshold,
      maxThreshold: double.infinity,
    );
  }

  /// Copy with new parameters
  ConfigurableBudgetStatusStrategy copyWith({
    String? statusText,
    Color? statusColor,
    IconData? statusIcon,
    double? minThreshold,
    double? maxThreshold,
  }) {
    return ConfigurableBudgetStatusStrategy(
      statusText: statusText ?? _statusText,
      statusColor: statusColor ?? _statusColor,
      statusIcon: statusIcon ?? _statusIcon,
      minThreshold: minThreshold ?? _minThreshold,
      maxThreshold: maxThreshold ?? _maxThreshold,
    );
  }
}
