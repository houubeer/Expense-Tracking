import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';

/// Centralized theme configuration for the expense tracking app
class AppTheme {
  AppTheme._();

  /// Light theme configuration
  static ThemeData get lightTheme {
    const lightColorScheme = ColorScheme(
      brightness: Brightness.light,

      // Primary colors - Deep Blue Theme
      primary: Color(0xFF28448B), // Deep Blue
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFF3d5a9e), // Lighter Blue
      onPrimaryContainer: Color(0xFF1a2a52), // Darker Blue

      // Secondary colors - Vibrant Indigo
      secondary: Color(0xFF6366F1), // Vibrant Indigo
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFF818CF8), // Light Indigo
      onSecondaryContainer: Color(0xFF1e1b4b),

      // Tertiary colors - Emerald Green
      tertiary: Color(0xFF10B981), // Emerald
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFF6ee7b7),
      onTertiaryContainer: Color(0xFF065f46),

      // Error colors
      error: Color(0xFFB3261E),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFF9DEDC),
      onErrorContainer: Color(0xFF410E0B),

      // Surface colors
      surface: Color(0xFFFFFBFE),
      onSurface: Color(0xFF1C1B1F),
      surfaceContainerHighest: Color(0xFFE7E0EC),
      onSurfaceVariant: Color(0xFF49454F),

      // Outline colors
      outline: Color(0xFF79747E),
      outlineVariant: Color(0xFFCAC4D0),

      // Shadow and other colors
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFF313033),
      onInverseSurface: Color(0xFFF4EFF4),
      inversePrimary: Color(0xFFD0BCFF),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme,

      // Typography
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.25,
          fontFamily: 'Raleway',
        ),
        displayMedium: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w400,
          fontFamily: 'Raleway',
        ),
        displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          fontFamily: 'Raleway',
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          fontFamily: 'Raleway',
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          fontFamily: 'Raleway',
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          fontFamily: 'Raleway',
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          fontFamily: 'Raleway',
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
          fontFamily: 'Raleway',
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          fontFamily: 'Raleway',
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          fontFamily: 'Raleway',
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          fontFamily: 'Raleway',
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          fontFamily: 'Raleway',
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          fontFamily: 'Raleway',
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          fontFamily: 'Raleway',
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          fontFamily: 'Raleway',
        ),
      ),

      // App bar theme
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: lightColorScheme.surface,
        foregroundColor: lightColorScheme.onSurface,
        surfaceTintColor: lightColorScheme.surfaceTint,
      ),

      // Card theme
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusXl)),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightColorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: BorderSide(
            color: lightColorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: BorderSide(
            color: lightColorScheme.error,
            width: 1,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
        ),
      ),

      // Filled button theme (Material 3)
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
        ),
      ),

      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
        ),
      ),

      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: lightColorScheme.primaryContainer,
        foregroundColor: lightColorScheme.onPrimaryContainer,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
      ),

      // Divider theme
      dividerTheme: DividerThemeData(
        color: lightColorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
      ),
    );
  }

  /// Dark theme configuration
  static ThemeData get darkTheme {
    const darkColorScheme = ColorScheme(
      brightness: Brightness.dark,

      // Primary colors - Deep Blue Dark Theme
      primary: Color.fromARGB(255, 0, 74, 144), // Lighter blue for dark mode
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer:
          Color.fromARGB(255, 201, 211, 241), // Darker blue container
      onPrimaryContainer: Color.fromARGB(255, 0, 34, 114),

      // Secondary colors - Indigo for dark mode
      secondary: Color(0xFF8B92E8), // Lighter indigo
      onSecondary: Color(0xFF1a1a2e),
      secondaryContainer: Color(0xFF4A4E8C),
      onSecondaryContainer: Color(0xFFD6D8F5),

      // Tertiary colors - Emerald for dark mode
      tertiary: Color(0xFF34D399), // Lighter emerald
      onTertiary: Color(0xFF003D2B),
      tertiaryContainer: Color(0xFF10B981),
      onTertiaryContainer: Color(0xFFA7F3D0),

      // Error colors
      error: Color(0xFFFF6B6B),
      onError: Color(0xFF370B0B),
      errorContainer: Color(0xFF8C1D18),
      onErrorContainer: Color(0xFFFFDADA),

      // Surface colors - Slightly lighter than background
      surface: Color.fromARGB(255, 0, 7, 45),
      onSurface: Color(0xFFE5E5E5),
      surfaceContainerHighest: Color.fromARGB(255, 86, 83, 102),
      onSurfaceVariant: Color(0xFFB8B8B8),

      // Outline colors
      outline: Color.fromARGB(255, 245, 245, 245),
      outlineVariant: Color.fromARGB(255, 97, 97, 97),

      // Shadow and other colors
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFFE5E5E5),
      onInverseSurface: Color(0xFF1A1A1A),
      inversePrimary: Color(0xFF28448B),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: darkColorScheme,

      // Typography (same as light theme)
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.25,
          fontFamily: 'Raleway',
        ),
        displayMedium: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w400,
          fontFamily: 'Raleway',
        ),
        displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          fontFamily: 'Raleway',
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          fontFamily: 'Raleway',
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          fontFamily: 'Raleway',
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          fontFamily: 'Raleway',
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          fontFamily: 'Raleway',
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
          fontFamily: 'Raleway',
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          fontFamily: 'Raleway',
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          fontFamily: 'Raleway',
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          fontFamily: 'Raleway',
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          fontFamily: 'Raleway',
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          fontFamily: 'Raleway',
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          fontFamily: 'Raleway',
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          fontFamily: 'Raleway',
        ),
      ),

      // App bar theme
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: darkColorScheme.surface,
        foregroundColor: darkColorScheme.onSurface,
        surfaceTintColor: darkColorScheme.surfaceTint,
      ),

      // Card theme
      cardTheme: const CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusLg)),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkColorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: BorderSide(
            color: darkColorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: BorderSide(
            color: darkColorScheme.error,
            width: 1,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
        ),
      ),

      // Filled button theme (Material 3)
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
        ),
      ),

      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
        ),
      ),

      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: darkColorScheme.primaryContainer,
        foregroundColor: darkColorScheme.onPrimaryContainer,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
      ),

      // Divider theme
      dividerTheme: DividerThemeData(
        color: darkColorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
      ),
    );
  }
}
