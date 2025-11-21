import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors (Inter/Slate inspired)
  static const primary = Color(0xFF0F172A); // Slate 900
  static const primaryLight = Color(0xFF334155); // Slate 700
  static const accent = Color(0xFF3B82F6); // Blue 500

  // Secondary Colors
  static const purple = Color(0xFF8B5CF6); // Violet 500
  static const pink = Color(0xFFEC4899); // Pink 500
  static const teal = Color(0xFF14B8A6); // Teal 500
  static const orange = Color(0xFFF97316); // Orange 500
  static const red = Color(0xFFEF4444); // Red 500
  static const green = Color(0xFF22C55E); // Green 500

  // Backgrounds
  static const background = Color(0xFFF8FAFC); // Slate 50
  static const surface = Color(0xFFFFFFFF); // White
  static const surfaceAlt = Color(0xFFF1F5F9); // Slate 100

  // Text Colors
  static const textPrimary = Color(0xFF0F172A); // Slate 900
  static const textSecondary = Color(0xFF64748B); // Slate 500
  static const textTertiary = Color(0xFF94A3B8); // Slate 400
  static const textInverse = Color(0xFFFFFFFF); // White

  // Borders & Dividers
  static const border = Color(0xFFE2E8F0); // Slate 200
  static const divider = Color(0xFFCBD5E1); // Slate 300

  // Legacy Mappings (to avoid breaking existing code immediately)
  static const primaryBlue = accent;
  static const secondaryBlue = primaryLight;
  static const grey200 = surfaceAlt;
  static const grey300 = border;
  static const grey = textSecondary;
  static const darkGrey = textPrimary;
  static const white = surface;
  static const black = textPrimary;
  static const tagBackground = surfaceAlt;
}
