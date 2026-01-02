import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for the current app locale.
/// When changed, the app's MaterialApp rebuilds with the new locale.
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en')) {
    _initializeLocale();
  }

  /// Initialize locale from SharedPreferences on app startup.
  Future<void> _initializeLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('language_code') ?? 'en';
      // Ensure state is updated even if it's the same value
      state = Locale(languageCode);
    } catch (e) {
      // Keep default English if error
      debugPrint('Error loading locale: $e');
    }
  }

  /// Change the app locale and persist it.
  Future<void> setLocale(String languageCode) async {
    // Always update state to trigger rebuilds
    state = Locale(languageCode);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', languageCode);
    } catch (e) {
      debugPrint('Error saving locale: $e');
    }
  }
}

