// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:my_yard/src/features/device/application/device_list_notifier.dart'; // Import the device list notifier

class DeviceScreen extends ConsumerWidget { // Changed to ConsumerWidget
  const DeviceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { // Add WidgetRef
    // Watch the device list notifier to get the current list of devices
    final asyncDevices = ref.watch(deviceListNotifierProvider);

    return Scaffold(
      // The AppBar is typically managed by HomeScreen if DeviceScreen is a tab.
      // If it were a standalone screen, an AppBar here would be appropriate.
      body: asyncDevices.when(
        data: (devices) {
          if (devices.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No devices are currently managed.\nUse the "Scan" tab to find and add devices.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            );
          }
          return ListView.builder(
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              // Ensure 'ip' is not null before using it as a key or identifier
              final deviceIp = device['ip'];
              if (deviceIp == null) {
                 // Handle cases where device data might be incomplete
                 return const SizedBox.shrink(); // Or a placeholder error item
              }

              return ListTile(
                key: ValueKey(deviceIp), // Use a unique key for list items
                leading: const Icon(Icons.developer_board_outlined),
                title: Text(device['name'] ?? 'Unknown Device'),
                subtitle: Text('IP: ${deviceIp} - Type: ${device['type'] ?? 'Unknown'}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  tooltip: 'Remove Device',
                  onPressed: () {
                    // Optional: Show a confirmation dialog before removing
                    ref.read(deviceListNotifierProvider.notifier).removeDevice(device);
                  },
                ),
                onTap: () {
                  // TODO: Implement navigation to a device detail/control screen
                  debugPrint('Tapped on device: ${device['name']}');
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Error loading devices: $err', textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}
