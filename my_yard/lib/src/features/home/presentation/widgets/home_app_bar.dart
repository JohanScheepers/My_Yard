// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_yard/src/constants/ui_constants.dart';
import 'package:my_yard/src/features/settings/presentation/settings_screen.dart';

/// A custom [AppBar] for the [HomeScreen].
///
/// Displays the current screen title, a tappable logo to return to home,
/// and a settings icon for navigation.
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({
    super.key,
    required this.appBarTitle,
    required this.onLogoTap,
  });

  final String appBarTitle;
  final VoidCallback onLogoTap;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(appBarTitle),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      leading: Padding(
        padding: const EdgeInsets.all(kSpaceSmall),
        child: InkWell(
          onTap: onLogoTap,
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
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
