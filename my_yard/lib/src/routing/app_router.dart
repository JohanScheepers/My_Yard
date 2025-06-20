// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_yard/src/features/home/presentation/home_screen.dart';
import 'package:my_yard/src/features/splash/presentation/splash_screen.dart';
import 'package:my_yard/src/constants/ui_constants.dart';
import 'package:my_yard/src/features/settings/presentation/settings_screen.dart';

// Route names for type-safe navigation
class AppRoute {
  static const String splash = 'splash';
  static const String home = 'home';
  static const String settings = 'settings'; // Added settings route name
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash', // Start with the splash screen
    debugLogDiagnostics: true, // Helpful for debugging routes
    routes: <RouteBase>[
      GoRoute(
        path: '/splash',
        name: AppRoute.splash,
        pageBuilder: (BuildContext context, GoRouterState state) {
          // Usually splash screens don't have exit transitions, but we can add one if needed.
          // For now, let's keep it simple or use a default transition.
          // Using builder here for simplicity, or you could define a specific transition.
          return MaterialPage(child: const SplashScreen(), key: state.pageKey);
        },
      ),
      GoRoute(
        path: '/home',
        name: AppRoute.home,
        pageBuilder: (BuildContext context, GoRouterState state) {
          // Define a custom transition for the HomeScreen
          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: const HomeScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              // Fade transition
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: kAnimationDurationMedium, // Using constant
          );
        },
      ),
      GoRoute(
        path: SettingsScreen
            .routeName, // Using the static routeName from SettingsScreen
        name: AppRoute.settings, // Using the new route name constant
        pageBuilder: (BuildContext context, GoRouterState state) {
          // Define a custom transition for the SettingsScreen
          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: const SettingsScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: kAnimationDurationMedium, // Using constant
          );
        },
      ),
    ],
  );
}
