import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_yard/src/constants/colors.dart';
import 'package:my_yard/src/constants/text_styles.dart';
import 'package:my_yard/src/utils/platform_info.dart';

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: kLightColorScheme,
    textTheme: kAppTextTheme.apply(
      bodyColor: kLightColorScheme.onSurface,
      displayColor: kLightColorScheme.onSurface,
    ),
    // Add other theme properties like appBarTheme, buttonTheme, etc.
    // e.g. appBarTheme: AppBarTheme(backgroundColor: kLightColorScheme.primaryContainer)
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: kDarkColorScheme,
    textTheme: kAppTextTheme.apply(
      bodyColor: kDarkColorScheme.onSurface,
      displayColor: kDarkColorScheme.onSurface,
    ),
    // Add other theme properties for dark theme
    // e.g. appBarTheme: AppBarTheme(backgroundColor: kDarkColorScheme.primaryContainer)
  );

  /// Returns a CupertinoThemeData appropriate for the current platform and theme brightness.
  ///
  /// If the platform is not iOS, returns null.
  static CupertinoThemeData? getPlatformSpecificCupertinoTheme(BuildContext context) {
    if (OperatingSys.isIOS) {
      final Brightness currentBrightness = Theme.of(context).brightness;
      final ColorScheme materialColorScheme =
          currentBrightness == Brightness.light
              ? lightTheme.colorScheme
              : darkTheme.colorScheme;

      return CupertinoThemeData(
        brightness: currentBrightness,
        primaryColor: materialColorScheme.primary,
        // You can further customize other CupertinoThemeData properties here,
        // e.g., barBackgroundColor, scaffoldBackgroundColor, etc.
      );
    }
    return null;
  }
}
