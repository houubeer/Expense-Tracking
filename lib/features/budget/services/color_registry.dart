import 'package:flutter/material.dart';

/// Registry for category colors (OCP compliance)
/// Allows adding new colors without modifying existing code
class ColorRegistry {
  factory ColorRegistry() => _instance;
  ColorRegistry._internal();
  static final ColorRegistry _instance = ColorRegistry._internal();

  final List<Color> _colors = [
    const Color(0xFF6366F1), // Indigo
    const Color(0xFFEC4899), // Pink
    const Color(0xFF8B5CF6), // Purple
    const Color(0xFF14B8A6), // Teal
    const Color(0xFFF59E0B), // Amber
    const Color(0xFFEF4444), // Red
    const Color(0xFF10B981), // Green
    const Color(0xFF3B82F6), // Blue
    const Color(0xFFF97316), // Orange
  ];

  /// Get all registered colors
  List<Color> get colors => List.unmodifiable(_colors);

  /// Register a new color (extends without modification)
  void registerColor(Color color) {
    if (!_colors.contains(color)) {
      _colors.add(color);
    }
  }

  /// Register multiple colors
  void registerColors(List<Color> colors) {
    for (final color in colors) {
      registerColor(color);
    }
  }

  /// Clear all colors (useful for testing)
  void clear() {
    _colors.clear();
  }

  /// Reset to default colors
  void resetToDefaults() {
    _colors.clear();
    _colors.addAll([
      const Color(0xFF6366F1), // Indigo
      const Color(0xFFEC4899), // Pink
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFF14B8A6), // Teal
      const Color(0xFFF59E0B), // Amber
      const Color(0xFFEF4444), // Red
      const Color(0xFF10B981), // Green
      const Color(0xFF3B82F6), // Blue
      const Color(0xFFF97316), // Orange
    ]);
  }
}
