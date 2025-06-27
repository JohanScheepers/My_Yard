// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:my_yard/src/features/device/domain/device.dart';

/// Placeholder screen for 'my_fish_tank' device type.
class MyFishTankScreen extends ConsumerWidget {
  // Changed to ConsumerWidget
  const MyFishTankScreen({super.key, required this.device});
  final Device device;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Added WidgetRef ref
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('My Fish Tank Screen'),
          Text('Device ID: ${device.id}'),
          Text('Device Type: ${device.nodeType}'),
        ],
      ),
    );
  }
}
