// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_yard/src/routing/app_router.dart';
import 'package:my_yard/src/constants/themes.dart';
import 'package:my_yard/src/features/settings/application/theme_notifier.dart'; // Import the theme notifier

void main() {
  runApp(
    // Wrap the app with ProviderScope for Riverpod
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget { // Changed to ConsumerWidget
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) { // Added WidgetRef
    // Use Consumer to watch the themeNotifierProvider
    final asyncThemeMode = ref.watch(themeNotifierProvider);

    return MaterialApp.router(
      routerConfig: ref.watch(goRouterProvider),
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme, // Your defined light theme
      darkTheme: AppThemes.darkTheme, // Your defined dark theme
      // Use the theme mode from the notifier, handle async state
      themeMode: asyncThemeMode.when(
        data: (appThemeMode) => appThemeMode.toFlutterThemeMode(),
        loading: () => ThemeMode.system, // Or your preferred loading theme
        error: (err, stack) => ThemeMode.system, // Or your preferred error theme
      ),
    );
  }
}
