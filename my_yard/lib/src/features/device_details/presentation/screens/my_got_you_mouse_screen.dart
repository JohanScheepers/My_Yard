// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:my_yard/src/features/device/domain/device.dart';

/// Placeholder screen for 'my_got_you_mouse' device type.
class MyGotYouMouseScreen extends ConsumerWidget {
  // Changed to ConsumerWidget
  const MyGotYouMouseScreen({super.key, required this.device});
  final Device device;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Added WidgetRef ref
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('My Got You Mouse Screen'),
          Text('Device ID: ${device.id}'),
          Text('Device Type: ${device.nodeType}'),
        ],
      ),
    );
  }
}
