// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_yard/src/routing/app_router.dart'; // For AppRoute.home
import 'package:my_yard/src/constants/ui_constants.dart';
import 'package:my_yard/src/features/device/application/device_list_notifier.dart';

// Asset path constant
const String kLogoPath = 'assets/logo/my_yard_name_256.png';

class SplashScreen extends ConsumerStatefulWidget { // Changed to ConsumerStatefulWidget
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState(); // Changed to ConsumerState
}

class _SplashScreenState extends ConsumerState<SplashScreen> { // Changed to ConsumerState
  @override
  void initState() {
    super.initState();
    _initializeAndNavigate();
  }

  Future<void> _navigateToHome() async {
    // Wait for a few seconds to display the splash screen
    await Future.delayed(const Duration(seconds: 5));
    if (mounted) {
      // Navigate to the home screen using named route
      context.goNamed(AppRoute.home);
    }
  }

  Future<void> _initializeAndNavigate() async {
    // Ensure the DeviceListNotifier is initialized and starts loading its data.
    // We don't need to explicitly wait for the future here, as the UI consuming
    // this provider will handle its AsyncValue states (loading, data, error).
    ref.read(deviceListNotifierProvider);

    // Original delay for splash screen visibility
    await Future.delayed(const Duration(seconds: 3)); // Adjusted for quicker testing if needed
    if (mounted) {
      context.goNamed(AppRoute.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Image.asset( // Using Image.asset as per lint suggestion
              kLogoPath,
              // Consider adding width/height constraints if needed
              // width: 200,
            ),
          ),
          kVerticalSpacerLarge, // Using constant for spacing
          Text(
            'Your Smart Yard, Simplified.',
            // Using a style from the app's theme
            // You can choose other styles like .bodyLarge, .headlineSmall etc.
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
