// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_notifier.g.dart'; // Generated file

/// Enum to represent the available theme modes.
enum AppThemeMode {
  system,
  light,
  dark,
}

/// Manages the application's theme mode and persists it using SharedPreferences.
@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  static const _themeModeKey = 'themeMode';

  @override
  Future<AppThemeMode> build() async {
    final prefs = await SharedPreferences.getInstance();
    final savedThemeMode = prefs.getString(_themeModeKey);

    if (savedThemeMode == null) {
      return AppThemeMode.system; // Default to system theme if nothing is saved
    }

    return AppThemeMode.values.firstWhere(
      (mode) => mode.name == savedThemeMode,
      orElse: () => AppThemeMode.system, // Fallback if saved value is invalid
    );
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    state = AsyncData(mode); // Update the state immediately
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name); // Save the preference
  }
}

/// Extension to convert AppThemeMode to Flutter's ThemeMode.
extension AppThemeModeExtension on AppThemeMode {
  ThemeMode toFlutterThemeMode() {
    switch (this) {
      case AppThemeMode.system: return ThemeMode.system;
      case AppThemeMode.light: return ThemeMode.light;
      case AppThemeMode.dark: return ThemeMode.dark;
    }
  }
}