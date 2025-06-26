// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard

import 'package:flutter/material.dart';

/// A custom [NavigationRail] for the [HomeScreen] on wider screens.
///
/// Displays navigation items for Home, Scan, and Config screens.
class HomeNavigationRail extends StatelessWidget {
  const HomeNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      labelType: NavigationRailLabelType.all,
      destinations: const [
        NavigationRailDestination(icon: Icon(Icons.home), label: Text('Home')),
        NavigationRailDestination(
            icon: Icon(Icons.scanner), label: Text('Scan')),
        NavigationRailDestination(
            icon: Icon(Icons.settings_applications), label: Text('Config')),
      ],
    );
  }
}
