import 'package:flutter/material.dart';

/// Interface for budget status strategies (Open/Closed Principle)
/// New status types can be added without modifying existing code
abstract class IBudgetStatusStrategy {
  String get statusText;
  Color get statusColor;
  IconData get statusIcon;
  bool matches(double percentage);
}
