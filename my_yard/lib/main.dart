import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // For CupertinoTheme and CupertinoThemeData
import 'package:my_yard/src/routing/app_router.dart';
import 'package:my_yard/src/constants/themes.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}



class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AppRouter.router,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.system, // Or ThemeMode.light, ThemeMode.dark
      builder: (context, child) {
        // Ensure child is not null, which should be handled by GoRouter.
        if (child == null) {
          return const SizedBox.shrink();
        }

        final String currentOS = Platform.operatingSystem;

        switch (currentOS) {
          case 'ios':
            // Apply Cupertino specific theme for Cupertino widgets when on iOS.
            // Determine the current brightness to match Material theme.
            final Brightness currentBrightness = Theme.of(context).brightness;
            final ColorScheme materialColorScheme =
                currentBrightness == Brightness.light
                    ? AppThemes.lightTheme.colorScheme
                    : AppThemes.darkTheme.colorScheme;

            return CupertinoTheme(
              data: CupertinoThemeData(
                brightness: currentBrightness,
                primaryColor: materialColorScheme.primary,
                // You can further customize other CupertinoThemeData properties here,
                // e.g., barBackgroundColor, scaffoldBackgroundColor, etc.
              ),
              child: child,
            );
          case 'android':
            // Android uses the Material theme by default, which is already set up.
            // Return child directly.
            return child;
          default:
            // For other platforms, return the child directly.
            return child;
        }
      },
    );
  }
}
