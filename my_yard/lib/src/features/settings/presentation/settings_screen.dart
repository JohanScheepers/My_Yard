// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Import go_router for context.pop()
import 'package:my_yard/src/features/settings/application/unit_notifier.dart'; // Import the new unit notifier
import 'package:my_yard/src/constants/ui_constants.dart'; // Import UI constants
import 'package:my_yard/src/features/settings/application/theme_notifier.dart'; // Import the theme notifier

class SettingsScreen extends ConsumerWidget {
  // Change to ConsumerWidget
  const SettingsScreen({super.key});

  // It's good practice to define a routeName for navigation,
  // especially when using a routing package like go_router.
  static const String routeName = '/settings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Add WidgetRef
    // Watch the theme notifier to get the current theme mode
    final currentThemeMode = ref.watch(themeNotifierProvider); // Existing
    final currentUnitSystem =
        ref.watch(unitNotifierProvider); // Watch the new unit notifier

    // Check if we can pop, to decide whether to show a back button
    final canPop = context.canPop();

    return Scaffold(
      appBar: AppBar(
        // Add the back button here
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  context.pop(); // Navigate back using go_router
                },
              )
            : null, // No back button if it can't pop
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        // Using constants
        padding:
            const EdgeInsets.all(kSpaceMedium), // Increased padding around the card
        children: [
          Card(
            clipBehavior: Clip.antiAlias,
            elevation:
                kCardElevationDefault, // Slightly increased elevation for more prominence
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Theme Preference Section ---
                Container(
                  // Using constants
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceVariant, // Subtle background for the section
                  padding: const EdgeInsets.symmetric(
                      vertical: kSpaceSmall), // Padding for the section container
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        // Using constants
                        padding: kSettingsSectionTitlePadding, // Adjusted padding
                        child: Text(
                          'Theme Preference',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold, // Make title bolder
                              ),
                        ),
                      ),
                      currentThemeMode.when(
                        data: (mode) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: AppThemeMode.values.map((themeModeOption) {
                            return RadioListTile<AppThemeMode>(
                              title: Text(themeModeOption.name[0].toUpperCase() +
                                  themeModeOption.name.substring(1)),
                              value: themeModeOption,
                              groupValue: mode,
                              onChanged: (value) {
                                if (value != null) {
                                  ref
                                      .read(themeNotifierProvider.notifier)
                                      .setThemeMode(value);
                                }
                              },
                            );
                          }).toList(),
                        ),
                        loading: () => const Padding(
                          padding:
                              EdgeInsets.all(kSpaceMedium), // Using constant
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (err, stack) => Padding(
                          padding: const EdgeInsets.all(
                              kSpaceMedium), // Using constant
                          child:
                              Center(child: Text('Error loading theme: $err')),
                        ),
                      ),
                    ],
                  ),
                ),

                // Divider between sections within the card
                const Divider(
                    height: 1,
                    thickness: kDividerThickness,
                    indent: kDividerIndent,
                    endIndent: kDividerIndent), // Using constants

                // --- Unit System Section ---
                Container(
                  // Using constants
                  color: Theme.of(context)
                      .colorScheme
                      .surface, // Default surface color for contrast
                  padding: const EdgeInsets.symmetric(vertical: kSpaceSmall),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        // Using constants
                        padding: kSettingsSectionTitlePadding,
                        child: Text(
                          'Unit System',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold, // Make title bolder
                              ),
                        ),
                      ),
                      currentUnitSystem.when(
                        data: (system) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: UnitSystem.values.map((unitSystemOption) {
                            return RadioListTile<UnitSystem>(
                              title: Text(unitSystemOption.name[0]
                                      .toUpperCase() +
                                  unitSystemOption.name.substring(1)),
                              value: unitSystemOption,
                              groupValue: system,
                              onChanged: (value) {
                                if (value != null) {
                                  ref
                                      .read(unitNotifierProvider.notifier)
                                      .setUnitSystem(value);
                                }
                              },
                            );
                          }).toList(),
                        ),
                        loading: () => const Padding(
                          padding:
                              EdgeInsets.all(kSpaceMedium), // Using constant
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (err, stack) => Padding(
                          padding: const EdgeInsets.all(
                              kSpaceMedium), // Using constant
                          child: Center(
                              child: Text('Error loading unit system: $err')),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
