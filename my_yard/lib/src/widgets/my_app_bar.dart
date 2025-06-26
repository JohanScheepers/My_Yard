import 'package:flutter/material.dart';
import 'package:my_yard/src/constants/ui_constants.dart';

/// A custom AppBar widget for the My Yard application.
///
/// This AppBar includes the application logo, a dynamic title,
/// and a settings icon for navigation.
class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// The title text to display in the AppBar.
  final String title;

  /// Callback function when the logo is tapped.
  final VoidCallback? onLogoTap;

  /// Callback function when the settings icon is pressed.
  final VoidCallback? onSettingsTap;

  /// Creates a [MyAppBar].
  const MyAppBar({
    super.key,
    required this.title,
    this.onLogoTap,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
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
          onPressed: onSettingsTap,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
