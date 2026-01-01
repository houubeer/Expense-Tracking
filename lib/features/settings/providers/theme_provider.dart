import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // Determine initial state, ideally read from shared_preferences
    // For now, default to system or match current hardcoded default
    return ThemeMode.system;
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    // Todo: Save to shared_preferences
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(() {
  return ThemeNotifier();
});
