// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard

import 'package:flutter/material.dart';
import 'package:my_yard/src/constants/ui_constants.dart';
import 'package:go_router/go_router.dart'; // Import go_router
import 'package:my_yard/src/features/settings/presentation/settings_screen.dart';

import 'package:my_yard/src/features/scan/presentation/scan_screen.dart'; // Import ScanScreen
import 'package:my_yard/src/features/config/presentation/config_screen.dart'; // Import ConfigScreen
import 'package:my_yard/src/features/home/application/navigation_index_provider.dart'; // Import navigationIndexProvider
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Keep this
import 'package:my_yard/src/features/device/application/device_list_notifier.dart'; // Import the new notifier
import 'package:my_yard/src/features/device/domain/device.dart'; // Import the Device model

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const String routeName = '/';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // HomeScreen is already a ConsumerWidget
    final selectedIndex = ref.watch(navigationIndexProvider);
    final navigationIndexNotifier = ref.read(navigationIndexProvider.notifier);

    String appBarTitle;
    switch (selectedIndex) {
      case 1:
        appBarTitle = 'Scan for Devices';
        break;
      case 2:
        appBarTitle = 'Configuration';
        break;
      case 0:
      default:
        appBarTitle = 'My Yard';
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: Padding(
          padding: const EdgeInsets.all(kSpaceSmall),
          child: InkWell(
            onTap: () {
              // Set the selected index to 0 (Home/My Yard) when the logo is tapped
              navigationIndexNotifier.state = 0;
            },
            child: Image.asset('assets/logo/my_yard_name.png'),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to the settings screen, allowing back navigation
              context.push(SettingsScreen.routeName);
            },
          ),
        ],
      ),
      body: _buildBody(context, ref, selectedIndex, navigationIndexNotifier),
      bottomNavigationBar: _buildBottomNavigationBar(
          context, ref, selectedIndex, navigationIndexNotifier),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, int selectedIndex,
      StateController<int> navigationIndexNotifier) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceListAsync = ref.watch(deviceListNotifierProvider);

        // Determine content based on selected index
        Widget currentContent;
        switch (selectedIndex) {
          case 0: // Home Screen - Device List
            currentContent = deviceListAsync.when(
              data: (devices) {
                if (devices.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No devices added yet. \n\nUse the "Scan" tab to find devices on your network.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18),
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
                          horizontal: 8.0, vertical: 4.0),
                      child: ListTile(
                        title:
                            Text('IP: ${device.ip}, Type: ${device.nodeType}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            // Pass device.id for removal, as removeDevice expects the device's unique ID
                            ref.read(deviceListNotifierProvider.notifier).removeDevice(device.id);
                          },
                        ),
                        onTap: () {
                          // TODO: Implement navigation to device details screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Tapped on device: ${device.ip}')),
                          );
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
            break;
          case 1: // Scan Screen
            currentContent = const ScanScreen();
            break;
          case 2: // Config Screen (Placeholder for now)
            currentContent = const ConfigScreen();
            break;
          default:
            currentContent = const Center(child: Text('Unknown Screen'));
        }

        if (constraints.maxWidth < 600) {
          // Narrow screen layout (e.g., phone)
          return currentContent;
        } else {
          // Wide screen layout (e.g., tablet, desktop)
          return Row(
            children: [
              NavigationRail(
                selectedIndex: selectedIndex,
                onDestinationSelected: (index) {
                  navigationIndexNotifier.state = index;
                },
                labelType: NavigationRailLabelType.all,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.scanner),
                    label: Text('Scan'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.settings_applications),
                    label: Text('Config'),
                  ),
                ],
              ),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(
                child: currentContent,
              ),
            ],
          );
        }
      },
    );
  }

  Widget? _buildBottomNavigationBar(BuildContext context, WidgetRef ref,
      int selectedIndex, StateController<int> navigationIndexNotifier) {
    // Only show BottomNavigationBar on narrow screens
    if (MediaQuery.of(context).size.width < 600) {
      return BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.scanner),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_applications),
            label: 'Config',
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: (index) {
          navigationIndexNotifier.state = index;
        },
      );
    }
    return null; // Don't show BottomNavigationBar on wide screens
  }
}
