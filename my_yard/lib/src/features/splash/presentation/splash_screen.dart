import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_yard/src/routing/app_router.dart'; // For AppRoute.home
import 'package:my_yard/src/constants/ui_constants.dart';

// Asset path constant
const String kLogoPath = 'assets/logo/my_yard_with_app_name.png';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    // Wait for a few seconds to display the splash screen
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      // Navigate to the home screen using named route
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
            child: Image( // LINT: Prefer `Image.asset` for named assets.
              image: AssetImage(kLogoPath),
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
