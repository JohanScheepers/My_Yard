// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:my_yard/src/features/settings/application/theme_notifier.dart'; // Import the theme notifier

class SettingsScreen extends ConsumerWidget { // Change to ConsumerWidget
  const SettingsScreen({super.key});

  // It's good practice to define a routeName for navigation,
  // especially when using a routing package like go_router.
  static const String routeName = '/settings';

  @override
  Widget build(BuildContext context, WidgetRef ref) { // Add WidgetRef
    // Watch the theme notifier to get the current theme mode
    final currentThemeMode = ref.watch(themeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView( // Use ListView for potential future settings
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Theme Preference',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          // Use when to handle the AsyncValue state
          currentThemeMode.when(
            data: (mode) => Column(
              mainAxisSize: MainAxisSize.min,
              children: AppThemeMode.values.map((themeModeOption) {
                return RadioListTile<AppThemeMode>(
                  title: Text(themeModeOption.name.toUpperCase()),
                  value: themeModeOption,
                  groupValue: mode,
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(themeNotifierProvider.notifier).setThemeMode(value);
                    }
                  },
                );
              }).toList(),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error loading theme: $err')),
          ),
        ],
      ),
    );
  }
}
