// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:my_yard/src/features/device/domain/device.dart';

/// Placeholder screen for 'my_tank_control_basic' device type.
class MyTankControlBasicScreen extends ConsumerWidget {
  // Changed to ConsumerWidget
  const MyTankControlBasicScreen({super.key, required this.device});
  final Device device;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Added WidgetRef ref
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Device Details:${device.nodeType}'),
          Text('Device IP: ${device.ip}'),
          Text('Device ID: ${device.id}'),
          Text('Time: ${device.currentTime}'),
        ],
      ),
    );
  }
}
