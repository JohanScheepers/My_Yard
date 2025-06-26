// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard

import 'package:flutter/material.dart';
import 'package:my_yard/src/constants/ui_constants.dart';
import 'package:go_router/go_router.dart';
import 'package:my_yard/src/features/scan/presentation/scan_screen.dart';
import 'package:my_yard/src/features/home/presentation/widgets/home_app_bar.dart';
import 'package:my_yard/src/features/home/presentation/widgets/home_bottom_navigation_bar.dart';
import 'package:my_yard/src/features/home/presentation/widgets/home_navigation_rail.dart';
import 'package:my_yard/src/features/home/presentation/widgets/home_device_list_view.dart';
import 'package:my_yard/src/features/config/presentation/config_screen.dart'; // Import ConfigScreen
import 'package:my_yard/src/features/home/application/navigation_index_provider.dart'; // Import navigationIndexProvider
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_yard/src/features/device/application/device_list_notifier.dart';

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

    // Determine the current body content based on the selected index
    Widget currentBodyContent;
    switch (selectedIndex) {
      case 0: // Home Screen - Device List
        final deviceListAsync = ref.watch(deviceListNotifierProvider);
        currentBodyContent = HomeDeviceListView(deviceListAsync: deviceListAsync);
        break;
      case 1: // Scan Screen
        currentBodyContent = const ScanScreen();
        break;
      case 2: // Config Screen
        currentBodyContent = const ConfigScreen();
        break;
      default:
        currentBodyContent = const Center(child: Text('Unknown Screen'));
    }

    return Scaffold(
      appBar: HomeAppBar(
        appBarTitle: appBarTitle,
        onLogoTap: () => navigationIndexNotifier.state = 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < kMobileBreakpointMax) {
            // Narrow screen layout (e.g., phone)
            return AnimatedSwitcher(
              duration: kAnimationDurationLong, // Use constant
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: currentBodyContent,
            );
          } else {
            // Wide screen layout (e.g., tablet, desktop)
            return Row(
              children: [
                HomeNavigationRail(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (index) => navigationIndexNotifier.state = index,
                ),
                const VerticalDivider(thickness: kDividerThickness, width: kDividerWidth),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: kAnimationDurationLong, // Use constant
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: currentBodyContent,
                  ),
                ),
              ],
            );
          }
        },
      ),
      bottomNavigationBar: MediaQuery.sizeOf(context).width < kMobileBreakpointMax
          ? HomeBottomNavigationBar(
              selectedIndex: selectedIndex,
              onTap: (index) => navigationIndexNotifier.state = index,
            )
          : null,
    );
  }
}
