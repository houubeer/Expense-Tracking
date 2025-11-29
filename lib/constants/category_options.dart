import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/features/budget/services/icon_registry.dart';
import 'package:expense_tracking_desktop_app/features/budget/services/color_registry.dart';

/// Category options using registry pattern (OCP compliance)
/// Icons and colors can now be extended without modifying this class
class CategoryIcons {
  static List<IconData> get icons => IconRegistry().icons;
}

/// Available colors for category selection
class CategoryColors {
  static List<Color> get colors => ColorRegistry().colors;
}
