// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Keep this import

class ConfigScreen extends ConsumerWidget {
  const ConfigScreen({super.key});

  static const String routeName = '/config';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: const Center(
        child: Text(
          'This is the Config Screen!',
        ),
      ),
    );
  }
}