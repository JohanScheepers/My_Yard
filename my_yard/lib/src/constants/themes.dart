import 'package:flutter/material.dart';
import 'package:my_yard/src/constants/colors.dart';
import 'package:my_yard/src/constants/text_styles.dart';

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: kLightColorScheme,
    textTheme: kAppTextTheme.apply(
      bodyColor: kLightColorScheme.onBackground,
      displayColor: kLightColorScheme.onBackground,
    ),
    // Add other theme properties like appBarTheme, buttonTheme, etc.
    // e.g. appBarTheme: AppBarTheme(backgroundColor: kLightColorScheme.primaryContainer)
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: kDarkColorScheme,
    textTheme: kAppTextTheme.apply(
      bodyColor: kDarkColorScheme.onBackground,
      displayColor: kDarkColorScheme.onBackground,
    ),
    // Add other theme properties for dark theme
    // e.g. appBarTheme: AppBarTheme(backgroundColor: kDarkColorScheme.primaryContainer)
  );
}
