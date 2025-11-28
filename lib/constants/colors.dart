import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors - Deep Blue Theme
  static const primary = Color(0xFF28448B); // Deep Blue
  static const primaryLight = Color(0xFF3d5a9e); // Lighter Blue
  static const primaryDark = Color(0xFF1a2a52); // Darker Blue for gradient
  static const accent = Color(0xFF6366F1); // Vibrant Indigo
  static const accentLight = Color(0xFF818CF8); // Light Indigo

  // Secondary Colors - Rich & Dynamic
  static const purple = Color(0xFF9333EA); // Rich Purple
  static const purpleLight = Color(0xFFA855F7); // Light Purple
  static const pink = Color(0xFFEC4899); // Vibrant Pink
  static const pinkLight = Color(0xFFF472B6); // Light Pink
  static const teal = Color(0xFF06B6D4); // Bright Cyan
  static const tealLight = Color(0xFF22D3EE); // Light Cyan
  static const orange = Color(0xFFF59E0B); // Amber
  static const orangeLight = Color(0xFFFBBF24); // Light Amber
  static const red = Color(0xFFEF4444); // Vibrant Red
  static const redLight = Color(0xFFF87171); // Light Red
  static const green = Color(0xFF10B981); // Emerald
  static const greenLight = Color(0xFF34D399); // Light Emerald

  // Gradient Colors
  static const gradientStart = Color(0xFF6366F1); // Indigo
  static const gradientMiddle = Color(0xFF8B5CF6); // Purple
  static const gradientEnd = Color(0xFFEC4899); // Pink

  // Backgrounds - Clean & Modern
  static const background = Color(0xFFF8FAFC); // Soft Gray
  static const surface = Color(0xFFFFFFFF); // Pure White
  static const surfaceAlt = Color(0xFFF1F5F9); // Light Gray
  static const surfaceDark = Color(0xFF0F172A); // Dark Surface

  // Text Colors
  static const textPrimary = Color(0xFF0F172A); // Almost Black
  static const textSecondary = Color(0xFF64748B); // Medium Gray
  static const textTertiary = Color(0xFF94A3B8); // Light Gray
  static const textInverse = Color(0xFFFFFFFF); // White

  // Borders & Dividers
  static const border = Color(0xFFE2E8F0); // Subtle Border
  static const divider = Color(0xFFCBD5E1); // Divider

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
