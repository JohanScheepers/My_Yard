// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard

import 'package:flutter/material.dart';
import 'package:my_yard/src/constants/ui_constants.dart';
import 'package:my_yard/src/features/scan/presentation/scan_screen.dart';
import 'package:go_router/go_router.dart'; // Import go_router
import 'package:my_yard/src/features/settings/presentation/settings_screen.dart';
import 'package:my_yard/src/features/config/presentation/config_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_yard/src/features/config/application/config_list_notifier.dart';

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
      'Welcome to My Yard!\nYour Smart Home Device Manager.',
      style: Theme.of(context).textTheme.titleLarge,
      textAlign: TextAlign.center,
    );

    final Widget actionButtonWidget = ElevatedButton(
      onPressed: () {
        // TODO: Implement a meaningful action for this button.
        debugPrint('Action button pressed!');
      },
      child: Text(useHorizontalLayout ? 'Action (Wide)' : 'Action'),
    );

    final Widget narrowScreenSpecificText = Text(
      'This layout is for smaller screens.',
      style: Theme.of(context).textTheme.bodyMedium,
      textAlign: TextAlign.center, // This text is now more general.
      // Adding a note about development status
      // This app is currently in active development. Features may change.
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
              kVerticalSpacerMedium,
              Text(
                'This app is currently in active development. Features may change.',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
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
      const ConfigScreen(),
    ];
  }

  @override
  void dispose() {
    super.dispose();
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
              icon: Icon(Icons.tune_outlined),
              selectedIcon: Icon(Icons.tune),
              label: Text('Config'),
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
              icon: Icon(Icons.tune),
              label: 'Config',
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
            duration: kAnimationDurationLong, // Using constant
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
          title: AnimatedSwitcher(
            // Using constant
            duration:
                kAnimationDurationMedium, // Duration for the text animation
            transitionBuilder: (Widget child, Animation<double> animation) {
              // Use a FadeTransition for the text
              return FadeTransition(opacity: animation, child: child);
            },
            child: Text(
              'My Yard - ${_getTabName(_selectedIndex)}',
              key: ValueKey<int>(
                  _selectedIndex), // Key is crucial for AnimatedSwitcher to recognize content change
            ),
          ),
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
                const VerticalDivider(
                    thickness: kDividerThickness,
                    width: kDividerThickness), // Using constant
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
        return 'Config'; // Changed tab name
      default:
        return '';
    }
  }
}

class DevicesWidget extends ConsumerWidget {
  const DevicesWidget({super.key});

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
                subtitle: Text('IP: $deviceIp'),
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

// // Copyright (c) [2025] Johan Scheepers
// // GitHub: https://github.com/JohanScheepers/My_Yard

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:my_yard/src/constants/ui_constants.dart';
// import 'package:my_yard/src/features/home/application/home_screen_notifier.dart'; // New import for selectedIndexProvider
// import 'package:my_yard/src/features/config/application/config_list_notifier.dart';
// import 'package:my_yard/src/features/config/domain/device_data.dart';
// import 'package:my_yard/src/features/scan/presentation/scan_screen.dart';
// import 'package:go_router/go_router.dart'; // Import go_router
// import 'package:my_yard/src/features/settings/presentation/settings_screen.dart';
// import 'package:my_yard/src/features/config/presentation/config_screen.dart';

// class HomeScreen extends ConsumerWidget {
//   HomeScreen({super.key});

//   // Key to preserve the state of the IndexedStack and its children (like ScanScreen)
//   final GlobalKey _indexedStackKey = GlobalKey(debugLabel: 'homeIndexedStack');

//   Widget _buildHomeContent(BoxConstraints constraints, WidgetRef ref) {
//     // Determine if a wide layout should be used based on the breakpoint
//     final bool useHorizontalLayout =
//         constraints.maxWidth >= kWideLayoutBreakpoint;

//     // Define common content widgets to avoid repetition
//     final Widget welcomeTextWidget = Text(
//       'Welcome to My Yard!\nYour Smart Home Device Manager.',
//       style: Theme.of(context).textTheme.titleLarge,
//       textAlign: TextAlign.center,
//     );

//     final Widget actionButtonWidget = ElevatedButton(
//       onPressed: () {
//         // TODO: Implement a meaningful action for this button.
//         debugPrint('Action button pressed!');
//       },
//       child: Text(useHorizontalLayout ? 'Action (Wide)' : 'Action'),
//     );

//     final asyncDevices = ref.watch(configListNotifierProvider);

//     final deviceListWidget = Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: kSpaceSmall),
//           child: Text(
//             'Configured Devices',
//             style: Theme.of(context).textTheme.titleMedium,
//           ),
//         ),
//         const Divider(),
//         Expanded(
//           child: asyncDevices.when(
//             data: (devices) {
//               if (devices.isEmpty) {
//                 return const Center(
//                   child: Text(
//                       'No devices configured. Use the "Scan" tab to add one.'),
//                 );
//               }
//               return ListView.builder(
//                 itemCount: devices.length,
//                 itemBuilder: (context, index) {
//                   final DeviceData device = devices[index];
//                   final hasHostname =
//                       device.hostname != null && device.hostname!.isNotEmpty;
//                   final titleText =
//                       hasHostname ? device.hostname! : device.ipAddress;
//                   return Card(
//                     elevation: kCardElevationLow,
//                     margin: const EdgeInsets.symmetric(vertical: kSpaceXSmall),
//                     child: ListTile(
//                       leading: const Icon(Icons.developer_board_outlined),
//                       title: Text(titleText),
//                       subtitle: Text('OS: ${device.os ?? 'N/A'}'),
//                       dense: true,
//                     ),
//                   );
//                 },
//               );
//             },
//             loading: () => const Center(child: CircularProgressIndicator()),
//             error: (err, stack) => Center(child: Text('Error: $err')),
//           ),
//         ),
//       ],
//     );

//     if (useHorizontalLayout) {
//       // Horizontal layout for wider screens
//       return Center(
//         child: Padding(
//           padding: kPagePadding,
//           child: Column(children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: <Widget>[
//                 Flexible(child: welcomeTextWidget),
//                 kHorizontalSpacerMedium,
//                 actionButtonWidget
//               ],
//             ),
//             kVerticalSpacerMedium,
//             Expanded(child: deviceListWidget),
//           ]),
//         ),
//       );
//     } else {
//       // Vertical layout for narrower screens
//       return Center(
//         child: Padding(
//           padding: kPagePadding,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               welcomeTextWidget,
//               kVerticalSpacerMedium,
//               actionButtonWidget,
//               kVerticalSpacerMedium,
//               Expanded(child: deviceListWidget),
//             ],
//           ),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // Define _widgetOptions directly in the build method or as a static final
//     final List<Widget> _widgetOptions = [
//       LayoutBuilder(builder: (context, constraints) {
//         return _buildHomeContent(constraints, ref); // Pass ref to _buildHomeContent
//       }),
//       const ScanScreen(),
//       const ConfigScreen(),
//     ];

//     final int selectedIndex = ref.watch(selectedIndexProvider); // Watch the selected index
//     final selectedIndexNotifier = ref.read(selectedIndexProvider.notifier); // Get the notifier

//     // The AppBar title might need to be dynamic if each tab should have a different title
//     // It now correctly reflects the selected tab name.
//     return LayoutBuilder(builder: (context, constraints) {
//       final bool useWideLayout = constraints.maxWidth >= kWideLayoutBreakpoint;
//       Widget? bottomNavBar;
//       Widget? navRail;

//       if (useWideLayout) { // NavigationRail for wide layouts
//         navRail = NavigationRail(
//           selectedIndex: selectedIndex,
//           onDestinationSelected: (index) {
//             selectedIndexNotifier.setIndex(index);
//           },
//           labelType: NavigationRailLabelType.all,
//           destinations: const <NavigationRailDestination>[
//             NavigationRailDestination(
//               icon: Icon(Icons.home_outlined),
//               selectedIcon: Icon(Icons.home),
//               label: Text('Home'),
//             ),
//             NavigationRailDestination(
//               icon: Icon(Icons.qr_code_scanner_outlined),
//               selectedIcon: Icon(Icons.qr_code_scanner),
//               label: Text('Scan'),
//             ),
//             NavigationRailDestination(
//               icon: Icon(Icons.tune_outlined),
//               selectedIcon: Icon(Icons.tune),
//               label: Text('Config'),
//             ),
//           ],
//         );
//       } else { // BottomNavigationBar for narrow layouts
//         bottomNavBar = BottomNavigationBar(
//           items: const <BottomNavigationBarItem>[
//             BottomNavigationBarItem(
//               icon: Icon(Icons.home),
//               label: 'Home',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.qr_code_scanner),
//               label: 'Scan',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.tune),
//               label: 'Config',
//             ),
//           ],
//           currentIndex: selectedIndex, // Use watched index
//           selectedItemColor: Theme.of(context).colorScheme.primary,
//           onTap: (index) {
//             selectedIndexNotifier.setIndex(index); // Update index via notifier
//           },
//         );
//       }

//       // Use IndexedStack to manage the selected screen and preserve its state.
//       // Wrap each child with AnimatedOpacity to animate transitions.
//       final List<Widget> animatedWidgetOptions = List.generate(
//         _widgetOptions.length,
//         (index) {
//           // Use Offstage to prevent unnecessary widget tree builds when not visible
//           // TickerMode ensures animations/timers only run when visible
//           return Offstage(
//             offstage: selectedIndex != index,
//             child: TickerMode(
//               enabled: selectedIndex == index,
//               child: AnimatedOpacity( // AnimatedOpacity for fade transition
//                 opacity: selectedIndex == index ? 1.0 : 0.0,
//                 duration: kAnimationDurationLong, // Using constant
//                 curve: Curves.easeInOut, // Adjust curve as needed
//                 // Ensure the child is interactive only when visible
//                 child: IgnorePointer(
//                   ignoring: selectedIndex != index,
//                   child: _widgetOptions[index],
//                 ),
//               ),
//             ),
//           );
//         },
//       );

//       // Use IndexedStack to manage the selected screen and preserve its state.
//       final Widget bodyContent = IndexedStack(
//         key: _indexedStackKey, // GlobalKey for IndexedStack
//         index: selectedIndex, // Use watched index
//         children: animatedWidgetOptions, // Use the animated children
//       );

//       return Scaffold(
//         appBar: AppBar(
//           title: AnimatedSwitcher( // Using constant
//             duration: kAnimationDurationMedium, // Duration for the text animation
//             transitionBuilder: (Widget child, Animation<double> animation) {
//               // Use a FadeTransition for the text
//               return FadeTransition(opacity: animation, child: child);
//             },
//             child: Text( // Use watched index for tab name
//               'My Yard - ${_getTabName(selectedIndex)}',
//               key: ValueKey<int>(selectedIndex), // Key is crucial for AnimatedSwitcher to recognize content change
//             ),
//           ),
//           backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.settings),
//               tooltip: 'Settings',
//               onPressed: () {
//                 // Navigate to the SettingsScreen using go_router
//                 context.push(SettingsScreen.routeName);
//               },
//             ),
//           ],
//         ),
//         body: useWideLayout
//             ? Row(children: [
//                 if (navRail != null) navRail,
//                 const VerticalDivider(thickness: kDividerThickness, width: kDividerThickness), // Using constant
//                 Expanded(child: bodyContent),
//               ])
//             : bodyContent,
//         bottomNavigationBar: bottomNavBar,
//       );
//     });
//   }
// }

// String _getTabName(int index) { // Moved to top-level function
//   switch (index) {
//     case 0:
//       return 'Home';
//     case 1:
//       return 'Scan';
//     case 2:
//       return 'Config';
//     default:
//       return '';
//   }
// }

// Converting a StatefulWidget to a ConsumerWidget in Flutter, especially when using Riverpod, is a common and beneficial refactoring step. It allows you to leverage Riverpod's reactive state management, reduce boilerplate, and improve testability and maintainability.

// The core idea is to move all mutable state and the logic that modifies it out of the State class and into Riverpod providers. The ConsumerWidget then simply "consumes" this state from the providers.

// Here's a step-by-step guide on how to perform this conversion in VS Code:

// Step 1: Identify and Extract Mutable State
// First, examine your StatefulWidget's State class. Identify all:

// Mutable state variables: Any int, bool, List, Map, or custom objects that change over time and cause the UI to rebuild (e.g., _selectedIndex, _isScanning).
// Methods that modify state: Functions that call setState() to update these variables.
// Lifecycle methods: initState(), dispose(), didChangeDependencies(), didUpdateWidget(). These will need to be handled differently.
// GlobalKeys: If your StatefulWidget uses GlobalKeys as fields of its State class, these often need to become top-level final variables or static final members of the new ConsumerWidget class, as GlobalKeys are not compile-time constants and should persist across widget rebuilds.
// Example (Original StatefulWidget):

// Let's consider a simple counter widget as an example:

// dart
//  Show full code block 
// // lib/features/counter/presentation/counter_screen.dart
// import 'package:flutter/material.dart';

// class CounterScreen extends StatefulWidget {
//   const CounterScreen({super.key});

//   @override
//   State<CounterScreen> createState() => _CounterScreenState();
// }

// class _CounterScreenState extends State<CounterScreen> {
//   int _counter = 0; // Mutable state

//   @override
//   void initState() {
//     super.initState();
//     // Some initialization logic
//     debugPrint('CounterScreen initialized');
//   }

//   void _incrementCounter() { // Method modifying state
//     setState(() {
//       _counter++;
//     });
//   }

//   @override
//   void dispose() {
//     // Cleanup logic
//     debugPrint('CounterScreen disposed');
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Counter')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text('You have pushed the button this many times:'),
//             Text(
//               '$_counter', // Accessing state
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter, // Calling method
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }
// Step 2: Create Riverpod Provider(s) for the State
// For each piece of mutable state and its associated logic, create a corresponding Riverpod provider. The riverpod_generator package is highly recommended for this as it reduces boilerplate.

// Add riverpod_annotation and riverpod_generator to pubspec.yaml:

// yaml
//  Show full code block 
// dependencies:
//   flutter_riverpod: ^2.6.1 # Ensure this is present
//   riverpod_annotation: ^2.6.1 # Add this

// dev_dependencies:
//   build_runner: ^2.4.15 # Ensure this is present
//   riverpod_generator: ^2.6.5 # Add this
// Then run flutter pub get in your terminal.

// Create a new file for your provider: Typically in lib/src/features/<feature_name>/application/.

// Example (Creating counter_notifier.dart):

// dart
//  Show full code block 
// // lib/src/features/counter/application/counter_notifier.dart
// import 'package:riverpod_annotation/riverpod_annotation.dart';

// part 'counter_notifier.g.dart'; // This file will be generated

// @riverpod // This annotation tells riverpod_generator to create a provider
// class Counter extends _$Counter { // Extend _$Counter (generated class)
//   @override
//   int build() {
//     // This method is called once when the provider is first accessed.
//     // It's similar to initState for a State object.
//     // You can perform initialization here.
//     return 0; // Initial state value
//   }

//   // Methods to modify the state
//   void increment() {
//     state++; // Directly modify 'state' (which is 'int' in this case)
//   }

//   // You can add other methods like decrement, reset, etc.
// }
// Step 3: Convert the Widget to ConsumerWidget
// Now, modify your original widget file:

// Change extends StatefulWidget to extends ConsumerWidget.
// Remove the State class (_CounterScreenState in the example).
// Update the build method signature: It should now be Widget build(BuildContext context, WidgetRef ref). The WidgetRef ref parameter is crucial for interacting with Riverpod providers.
// Replace state access:
// Instead of _counter, use ref.watch(counterProvider) to get the current value of the state. ref.watch makes the widget rebuild whenever the provider's state changes.
// Instead of calling _incrementCounter(), use ref.read(counterProvider.notifier).increment(). ref.read is used for one-time actions that don't need to cause the widget to rebuild.
// Handle lifecycle:
// initState logic from the State class should generally be moved to the build method of the Notifier class (as shown in Step 2) or handled using ref.watch and ref.listen in the ConsumerWidget's build method.
// dispose logic should be handled using ref.onDispose(() { /* cleanup */ }); within the provider's build method or the ConsumerWidget's build method (if the cleanup is specific to the widget's lifecycle).
// didChangeDependencies and didUpdateWidget logic can often be replaced by ref.listen or by logic within the provider's build method or its methods.
// Example (Converted ConsumerWidget):

// dart
//  Show full code block 
// // lib/src/features/counter/presentation/counter_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
// import 'package:my_yard/src/features/counter/application/counter_notifier.dart'; // Import your new provider

// class CounterScreen extends ConsumerWidget { // Changed to ConsumerWidget
//   const CounterScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) { // Added WidgetRef ref
//     // Watch the counter state from the provider.
//     // This will cause the widget to rebuild whenever the counter's state changes.
//     final counter = ref.watch(counterProvider);

//     // Example of handling lifecycle-like behavior with ref.listen
//     // This will print a message once when the provider is initialized
//     // and whenever its state changes.
//     ref.listen<int>(counterProvider, (previous, next) {
//       debugPrint('Counter changed from $previous to $next');
//     });

//     return Scaffold(
//       appBar: AppBar(title: const Text('Counter')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text('You have pushed the button this many times:'),
//             Text(
//               '$counter', // Display the state from the provider
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           // Read the notifier and call its method to update the state.
//           // ref.read is used because we don't need this button press to cause
//           // the button itself to rebuild, only the Text widget displaying the count.
//           ref.read(counterProvider.notifier).increment();
//         },
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }
// Step 4: Run Code Generation
// After creating or modifying any file with @riverpod annotations, you must run build_runner to generate the .g.dart files.

// Open your terminal in the project's root directory (e.g., d:\FlutterProjects\My_Yard\my_yard) and run:

// bash
// flutter pub run build_runner build --delete-conflicting-outputs
// For continuous development, you can use watch mode:

// bash
// flutter pub run build_runner watch --delete-conflicting-outputs
// VS Code will usually prompt you to run build_runner if it detects missing generated files, or you can manually trigger it from the command palette.

// VS Code Specifics and Tips:
// Auto-imports: VS Code's Dart/Flutter extension is usually good at suggesting and adding necessary imports (e.g., package:flutter_riverpod/flutter_riverpod.dart).
// Linting: Keep an eye on the "Problems" panel. Linting rules (especially from flutter_lints) will guide you on best practices and potential issues.
// Refactoring: Use VS Code's refactoring tools (right-click on code -> Refactor) to extract methods or widgets, which can help break down complex build methods.
// Hot Reload: After running build_runner, hot reload should work seamlessly for UI changes. If you change provider logic, a full hot restart might be necessary.
// By following these steps, you'll successfully convert your StatefulWidget to a ConsumerWidget, making your application more aligned with Riverpod's reactive and declarative principles.

