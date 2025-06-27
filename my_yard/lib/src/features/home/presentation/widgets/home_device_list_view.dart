// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_yard/src/constants/text_styles.dart';
import 'package:my_yard/src/constants/ui_constants.dart';
import 'package:my_yard/src/features/config/application/selected_device_provider.dart';
import 'package:my_yard/src/features/device/application/device_list_notifier.dart';
import 'package:my_yard/src/features/device/domain/device.dart';
import 'package:my_yard/src/features/home/application/navigation_index_provider.dart';

/// Displays a list of discovered devices or a message if no devices are added.
///
/// This widget is a [ConsumerWidget] to directly interact with Riverpod
/// providers for device data and actions.
class HomeDeviceListView extends ConsumerWidget {
  const HomeDeviceListView({
    super.key,
    required this.deviceListAsync,
  });

  final AsyncValue<List<Device>> deviceListAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return deviceListAsync.when(
      data: (devices) {
        if (devices.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(kSpaceMedium), // Using a constant
              child: Text(
                'No devices added yet. \n\nUse the "Scan" tab to find devices on your network.',
                textAlign: TextAlign.center,
                style: kAppTextTheme
                    .bodyLarge, // Use kAppTextTheme.bodyLarge directly
              ),
            ),
          );
        }
        return ListView.builder(
          itemCount: devices.length,
          itemBuilder: (context, index) {
            final device = devices[index];
            return Card(
              margin: const EdgeInsets.symmetric(
                  horizontal: kSpaceSmall, vertical: kSpaceXSmall),
              child: ListTile(
                title: Text(
                    'IP: ${device.ip}\nType: ${device.nodeType}\nID: ${device.id}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    // Directly call the notifier to remove the device
                    //                     // TODO: Implement navigation to device details screen
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   SnackBar(content: Text('Tapped on device: ${device.ip}')),

                    ref
                        .read(deviceListNotifierProvider.notifier)
                        .removeDevice(device.id);
                  },
                ),
                onTap: () {
                  // Set the selected device and navigate to the config screen
                  ref.read(selectedDeviceProvider.notifier).state = device;
                  ref.read(navigationIndexProvider.notifier).state = 2;
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading devices: $error'),
      ),
    );
  }
}
