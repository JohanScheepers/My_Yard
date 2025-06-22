// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard

import 'package:my_yard/src/constants/ui_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:my_yard/src/features/config/application/config_list_notifier.dart'; // Import the config list notifier

class ConfigScreen extends ConsumerWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the config list notifier to get the current list of devices
    final asyncDevices = ref.watch(configListNotifierProvider);

    return Scaffold(
      // The AppBar is typically managed by HomeScreen if this is a tab.
      body: asyncDevices.when(
        data: (devices) {
          if (devices.isEmpty) {
            return const Center(
              child: Padding(
                padding: kPagePadding,
                child: Text(
                  'No devices have been configured.\nUse the "Scan" tab to find and add devices.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16), // This could be a text style constant
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
                title: Text(device['type'] ?? 'Unknown Device'),
                subtitle: Text(
                    'IP: ${deviceIp}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors
                          .redAccent), // This color could be from the theme
                  tooltip: 'Remove Device',
                  onPressed: () {
                    // Optional: Show a confirmation dialog before removing
                    ref
                        .read(configListNotifierProvider.notifier)
                        .removeDevice(device);
                  },
                ),
                onTap: () {
                  // TODO: Implement navigation to a device detail/control screen
                  debugPrint('Tapped on device: ${device['ip']}');
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: kPagePadding,
            child: Text('Error loading devices: $err',
                textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}
