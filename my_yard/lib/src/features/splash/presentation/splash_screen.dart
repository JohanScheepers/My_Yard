// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_yard/src/routing/app_router.dart'; // For AppRoute.home
import 'package:my_yard/src/constants/ui_constants.dart';
import 'package:my_yard/src/features/config/application/config_list_notifier.dart';

// Asset path constant
const String kLogoPath = 'assets/logo/my_yard_name_256.png';

class SplashScreen extends ConsumerStatefulWidget {
  // Changed to ConsumerStatefulWidget
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() =>
      _SplashScreenState(); // Changed to ConsumerState
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  // Changed to ConsumerState
  @override
  void initState() {
    super.initState();
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    // Ensure the DeviceListNotifier is initialized and starts loading its data.
    // We don't need to explicitly wait for the future here, as the UI consuming
    // this provider will handle its AsyncValue states (loading, data, error).
    ref.read(configListNotifierProvider);

    // Original delay for splash screen visibility
    await Future.delayed(
        const Duration(seconds: 5)); // Adjusted for quicker testing if needed
    if (mounted) {
      context.goNamed(AppRoute.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool isWide = constraints.maxWidth >
              kMobileBreakpointMax; // Define your breakpoint for wide layout
          return isWide
              ? _buildWideLayout(context)
              : _buildNarrowLayout(context);
        },
      ),
    );
  }

  Widget _buildNarrowLayout(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Center(
          child: Image.asset(
            kLogoPath,
          ),
        ),
        kVerticalSpacerLarge,
        Text(
          'Your Smart Yard, Simplified.',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        kVerticalSpacerSmall,
        const FlutterLogo(
          size: kFlutterLogoSize,
        ),
        kVerticalSpacerSmall,
        ClipOval(
          child: Image.asset(
            'assets/logo/gemini.jpg',
            width: kLogoSizeMedium,
            height: kLogoSizeMedium,
          ),
        ),
        kVerticalSpacerSmall,
        Text(
          'Powered by Flutter and Gemini',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                kLogoPath,
              ),
              kVerticalSpacerLarge,
              Text(
                'Your Smart Yard, Simplified.',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const FlutterLogo(
                size: kFlutterLogoSize,
              ),
              kVerticalSpacerSmall,
              ClipOval(
                child: Image.asset(
                  'assets/logo/gemini.jpg',
                  width: kLogoSizeMedium,
                  height: kLogoSizeMedium,
                ),
              ),
              kVerticalSpacerSmall,
              Text(
                'Powered by Flutter and Gemini',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
