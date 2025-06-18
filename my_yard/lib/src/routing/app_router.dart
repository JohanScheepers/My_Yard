// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_yard/src/features/home/presentation/home_screen.dart';
import 'package:my_yard/src/features/splash/presentation/splash_screen.dart';

// Route names for type-safe navigation
class AppRoute {
  static const String splash = 'splash';
  static const String home = 'home';
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash', // Start with the splash screen
    debugLogDiagnostics: true, // Helpful for debugging routes
    routes: <RouteBase>[
      GoRoute(
        path: '/splash',
        name: AppRoute.splash,
        builder: (BuildContext context, GoRouterState state) {
          return const SplashScreen();
        },
      ),
      GoRoute(
        path: '/home',
        name: AppRoute.home,
        builder: (BuildContext context, GoRouterState state) {
          return const HomeScreen();
        },
      ),
    ],
  );
}
