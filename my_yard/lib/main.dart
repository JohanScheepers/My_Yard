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

        final cupertinoTheme = AppThemes.getPlatformSpecificCupertinoTheme(context);

        if (cupertinoTheme != null) {
          return CupertinoTheme(data: cupertinoTheme, child: child);
        }
        // For non-iOS platforms or if no specific Cupertino theme is needed,
        // return the child directly.
        return child;
      },
    );
  }
}
