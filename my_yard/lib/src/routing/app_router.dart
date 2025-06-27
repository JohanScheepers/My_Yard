import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_yard/src/features/device/domain/device.dart';
import 'package:my_yard/src/features/config/presentation/config_screen.dart';
import 'package:my_yard/src/features/home/presentation/home_screen.dart';
import 'package:my_yard/src/features/splash/presentation/splash_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

enum AppRoute {
  splash,
  home,
  config,
}

@riverpod
GoRouter goRouter(GoRouterRef ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true, // Helpful for debugging routing issues
    routes: [
      GoRoute(
        path: '/',
        name: AppRoute.splash.name,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/home',
        name: AppRoute.home.name,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        // This is now a top-level route to ensure unambiguous navigation.
        path: '/config',
        name: AppRoute.config.name,
        builder: (context, state) {
          // Ensure the 'extra' parameter is the correct type.
          final device = state.extra is Device ? state.extra as Device : null;
          return ConfigScreen(device: device);
        },
      ),
    ],
  );
}
