// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'unit_notifier.g.dart'; // Generated file

/// Enum to represent the available unit systems.
enum UnitSystem {
  metric,
  imperial,
}

/// Manages the application's unit system preference and persists it using SharedPreferences.
@riverpod
class UnitNotifier extends _$UnitNotifier {
  static const _unitSystemKey = 'unitSystem';

  @override
  Future<UnitSystem> build() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUnitSystem = prefs.getString(_unitSystemKey);

    if (savedUnitSystem == null) {
      return UnitSystem.metric; // Default to metric if nothing is saved
    }

    return UnitSystem.values.firstWhere(
      (system) => system.name == savedUnitSystem,
      orElse: () => UnitSystem.metric, // Fallback if saved value is invalid
    );
  }

  Future<void> setUnitSystem(UnitSystem system) async {
    state = AsyncData(system); // Update the state immediately
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_unitSystemKey, system.name); // Save the preference
  }
}
