import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart'; // For Cupertino widgets
import 'package:flutter/material.dart';
import 'package:my_yard/src/constants/ui_constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isIOS = Platform.isIOS;

    // Define a breakpoint for wide layouts
    const double wideLayoutBreakpoint = 600.0;

    Widget buildContent(BoxConstraints constraints) {
      // Determine if a wide layout should be used based on the breakpoint
      final bool useHorizontalLayout =
          constraints.maxWidth >= wideLayoutBreakpoint;

      // Define common content widgets to avoid repetition
      final Widget welcomeTextWidget = Text(
        useHorizontalLayout
            ? 'Welcome to My Yard! (Wide Screen)'
            : (isIOS
                ? 'Welcome to My Yard on iOS!'
                : 'Welcome to My Yard on Android!'),
        style: Theme.of(context).textTheme.titleLarge,
        textAlign: TextAlign.center,
      );

      final Widget actionButtonWidget = isIOS
          ? CupertinoButton.filled(
              onPressed: () {
                // iOS specific action
                debugPrint('iOS Action Tapped');
              },
              child:
                  Text(useHorizontalLayout ? 'iOS Action (Wide)' : 'iOS Action'),
            )
          : ElevatedButton(
              onPressed: () {
                // Android specific action
                debugPrint('Android Action Tapped');
              },
              child: Text(useHorizontalLayout
                  ? 'Android Action (Wide)'
                  : 'Android Action'),
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
                actionButtonWidget,
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

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final String platformTitle = isIOS ? 'iOS' : 'Android';
        final String sizeIndicator =
            constraints.maxWidth >= wideLayoutBreakpoint ? "(Wide)" : "(Narrow)";
        final String appBarTitle = 'My Yard - $platformTitle $sizeIndicator';

        if (isIOS) {
          // iOS specific UI
          return CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              middle: Text(appBarTitle),
            ),
            child: buildContent(constraints),
          );
        } else {
          // Android (and other platforms) specific UI
          return Scaffold(
            appBar: AppBar(
              title: Text(appBarTitle),
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            ),
            body: buildContent(constraints),
          );
        }
      },
    );
  }
}
