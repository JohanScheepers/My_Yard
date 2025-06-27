// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_yard/src/features/device_details/presentation/screens/my_appliance_screen.dart';
import 'package:my_yard/src/features/device_details/presentation/screens/my_auto_gate_and_garage_door_screen.dart';
import 'package:my_yard/src/features/device_details/presentation/screens/my_fish_tank_screen.dart';
import 'package:my_yard/src/features/device_details/presentation/screens/my_fridge_screen.dart';
import 'package:my_yard/src/features/device_details/presentation/screens/my_go_mole_screen.dart';
import 'package:my_yard/src/features/device_details/presentation/screens/my_got_you_mouse_screen.dart';
import 'package:my_yard/src/features/device_details/presentation/screens/my_irrigation_screen.dart';
import 'package:my_yard/src/features/device_details/presentation/screens/my_lights_screen.dart';
import 'package:my_yard/src/features/device_details/presentation/screens/my_shopping_list_screen.dart';
import 'package:my_yard/src/features/device_details/presentation/screens/my_tank_control_basic_screen.dart';
import 'package:my_yard/src/features/device_details/presentation/screens/unsupported_device_screen.dart';
import 'package:my_yard/src/features/device/domain/device.dart';

/// A screen that displays configuration options for a specific device.
///
/// It dynamically shows different configuration widgets based on the
/// [device.nodeType].
class ConfigScreen extends ConsumerWidget {
  const ConfigScreen({super.key, this.device});

  final Device? device;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use a local variable for the device to avoid null checks with `!`.
    final currentDevice = device;

    // If no device is passed, show a message. This can happen if the
    // route is accessed directly without providing a device.
    if (currentDevice == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Configuration Error'),
        ),
        body: const Center(
          child: Text('No device selected.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Configure ${currentDevice.nodeType}'),
      ),
      body: _buildConfigWidget(currentDevice, context),
    );
  }

  /// Builds the specific configuration widget based on the device's nodeType.
  Widget _buildConfigWidget(Device device, BuildContext context) {
    switch (device.nodeType) {
      case 'my_appliance':
        return MyApplianceScreen(device: device);
      case 'my_auto_gate_and_garage_door':
        return MyAutoGateAndGarageDoorScreen(device: device);
      case 'my_fish_tank':
        return MyFishTankScreen(device: device);
      case 'my_fridge':
        return MyFridgeScreen(device: device);
      case 'my_go_mole':
        return MyGoMoleScreen(device: device);
      case 'my_got_you_mouse':
        return MyGotYouMouseScreen(device: device);
      case 'my_irrigation':
        return MyIrrigationScreen(device: device);
      case 'my_lights':
        return MyLightsScreen(device: device);
      case 'my_shopping_list':
        return MyShoppingListScreen(device: device);
      case 'my_tank_control_basic':
        return MyTankControlBasicScreen(device: device);
      default:
        return UnsupportedDeviceScreen(nodeType: device.nodeType);
    }
  }
}
