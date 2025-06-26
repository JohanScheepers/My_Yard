// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_yard/src/features/config/presentation/config_screen.dart';
import 'package:my_yard/src/features/home/presentation/home_screen.dart';
import 'package:my_yard/src/features/splash/presentation/splash_screen.dart';
import 'package:my_yard/src/constants/ui_constants.dart';
import 'package:my_yard/src/features/settings/presentation/settings_screen.dart';

// Route names for type-safe navigation
class AppRoute {
  static const String splash = 'splash';
  static const String home = 'home';
  static const String settings = 'settings';
  static const String config = 'config';
}

/// Helper function for building a page with a custom slide transition.
CustomTransitionPage<T> _buildPageWithSlideTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Define the slide offset.
      // For push: animation goes from 0.0 to 1.0 (slides in from right)
      // For pop: animation goes from 1.0 to 0.0 (slides out to right)
      const begin = Offset(1.0, 0.0); // Start from right
      const end = Offset.zero; // End at current position
      final tween = Tween(begin: begin, end: end);
      final offsetAnimation = animation.drive(tween);

      return SlideTransition(position: offsetAnimation, child: child);
    },
    transitionDuration: kAnimationDurationMedium,
  );
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
        pageBuilder: (context, state) => _buildPageWithSlideTransition<void>(
          context: context,
          state: state,
          child: const HomeScreen(),
        ),
      ),
      GoRoute(
        path: SettingsScreen.routeName,
        name: AppRoute.settings,
        pageBuilder: (context, state) => _buildPageWithSlideTransition<void>(
          context: context,
          state: state,
          child: const SettingsScreen(),
        ),
      ),
      GoRoute(
        path: ConfigScreen.routeName,
        name: AppRoute.config,
        pageBuilder: (context, state) => _buildPageWithSlideTransition<void>(
          context: context,
          state: state,
          child: const ConfigScreen(),
        ),
      ),
    ],
  );
}
