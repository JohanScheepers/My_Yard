// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard

import 'package:flutter/material.dart';
import 'package:my_yard/src/constants/ui_constants.dart';
import 'package:my_yard/src/features/scan/presentation/scan_screen.dart';
import 'package:go_router/go_router.dart'; // Import go_router
import 'package:my_yard/src/features/settings/presentation/settings_screen.dart';
import 'package:my_yard/src/features/device/presentation/device_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Key to preserve the state of the IndexedStack and its children (like ScanScreen)
  final GlobalKey _indexedStackKey = GlobalKey(debugLabel: 'homeIndexedStack');

  Widget _buildHomeContent(BoxConstraints constraints) {
    // Determine if a wide layout should be used based on the breakpoint
    final bool useHorizontalLayout =
        constraints.maxWidth >= kWideLayoutBreakpoint;

    // Define common content widgets to avoid repetition
    final Widget welcomeTextWidget = Text(
      useHorizontalLayout
          ? 'Welcome to My Yard! (Wide Layout)'
          : 'Welcome to My Yard!',
      style: Theme.of(context).textTheme.titleLarge,
      textAlign: TextAlign.center,
    );

    final Widget actionButtonWidget = ElevatedButton(
      onPressed: () {
        debugPrint('Action Tapped');
      },
      child: Text(useHorizontalLayout ? 'Action (Wide)' : 'Action'),
    );

    final Widget narrowScreenSpecificText = Text(
      'This layout is for smaller screens.',
      style: Theme.of(context).textTheme.bodyMedium,
      textAlign: TextAlign.center,
    );

    if (useHorizontalLayout) {
      // Horizontal layout for wider screens
      return Center(
        child: Padding(
          padding: kPagePadding, // Using constant for padding
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Flexible(child: welcomeTextWidget),
              kHorizontalSpacerMedium, // Using constant for spacing
              actionButtonWidget
            ],
          ),
        ),
      );
    } else {
      // Vertical layout for narrower screens
      return Center(
        child: Padding(
          padding: kPagePadding, // Using constant for padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              welcomeTextWidget,
              kVerticalSpacerMedium, // Using constant for spacing
              actionButtonWidget,
              kVerticalSpacerMedium, // Using constant for spacing
              narrowScreenSpecificText,
            ],
          ),
        ),
      );
    }
  }

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      LayoutBuilder(builder: (context, constraints) {
        return _buildHomeContent(constraints);
      }),
      const ScanScreen(),
      const DeviceScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      // No need for _previousIndex with AnimatedOpacity
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // The AppBar title might need to be dynamic if each tab should have a different title
    // It now correctly reflects the selected tab name.
    return LayoutBuilder(builder: (context, constraints) {
      final bool useWideLayout = constraints.maxWidth >= kWideLayoutBreakpoint;
      Widget? bottomNavBar;
      Widget? navRail;

      if (useWideLayout) {
        navRail = NavigationRail(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          labelType: NavigationRailLabelType.all,
          destinations: const <NavigationRailDestination>[
            NavigationRailDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: Text('Home'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.qr_code_scanner_outlined),
              selectedIcon: Icon(Icons.qr_code_scanner),
              label: Text('Scan'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.devices_outlined),
              selectedIcon: Icon(Icons.devices),
              label: Text('Device'),
            ),
          ],
        );
      } else {
        bottomNavBar = BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner),
              label: 'Scan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.devices),
              label: 'Device',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          onTap: _onItemTapped,
        );
      }

      // Use IndexedStack to manage the selected screen and preserve its state.
      // Wrap each child with AnimatedOpacity to animate transitions.
      final List<Widget> animatedWidgetOptions = List.generate(
        _widgetOptions.length,
        (index) {
          // AnimatedOpacity handles the transition when its opacity changes.
          // The opacity is 1.0 for the selected index, 0.0 otherwise.
          return AnimatedOpacity(
            opacity: _selectedIndex == index ? 1.0 : 0.0,
            duration:
                const Duration(milliseconds: 500), // Adjust duration as needed
            curve: Curves.easeInOut, // Adjust curve as needed
            // Ensure the child is interactive only when visible
            child: IgnorePointer(
              ignoring: _selectedIndex != index,
              child: _widgetOptions[index],
            ),
          );
        },
      );

      // Use IndexedStack to manage the selected screen and preserve its state.
      final Widget bodyContent = IndexedStack(
        key: _indexedStackKey, // Assign the GlobalKey here
        index:
            _selectedIndex, // IndexedStack still needs the index to stack correctly
        children: animatedWidgetOptions, // Use the animated children
      );

      return Scaffold(
        appBar: AppBar(
          title: Text('My Yard - ${_getTabName(_selectedIndex)}'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Settings',
              onPressed: () {
                // Navigate to the SettingsScreen using go_router
                context.push(SettingsScreen.routeName);
              },
            ),
          ],
        ),
        body: useWideLayout
            ? Row(children: [
                if (navRail != null) navRail,
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: bodyContent),
              ])
            : bodyContent,
        bottomNavigationBar: bottomNavBar,
      );
    });
  }

  String _getTabName(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Scan'; // Changed tab name
      case 2:
        return 'Device'; // Changed tab name
      default:
        return '';
    }
  }
}
