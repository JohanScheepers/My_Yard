import 'package:flutter/material.dart';
import 'package:my_yard/src/constants/ui_constants.dart';
import 'package:my_yard/src/features/scan/presentation/scan_screen.dart';
import 'package:my_yard/src/features/device/presentation/device_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  Widget _buildHomeContent(BoxConstraints constraints) {
    // Determine if a wide layout should be used based on the breakpoint
    final bool useHorizontalLayout = constraints.maxWidth >= kWideLayoutBreakpoint;

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
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // The AppBar title might need to be dynamic if each tab should have a different title
    // For now, it reflects the general HomeScreen and its responsive state.
    // We use a LayoutBuilder here just to update the AppBar title based on width,
    // but the main content switching is handled by _selectedIndex.
    return Scaffold(
      appBar: AppBar(
        title: LayoutBuilder( // To make AppBar title responsive if needed
          builder: (context, constraints) {            
            // You might want a more sophisticated way to set titles per tab
            //return Text('My Yard - ${_getTabName(_selectedIndex)} $sizeIndicator');
             return Text(
              'My Yard - ${_getTabName(_selectedIndex)}');
          }
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner), // Changed icon
            label: 'Scan', // Changed label
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.devices), // Changed icon
            label: 'Device', // Changed label
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: _onItemTapped,
      ),
    );
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
