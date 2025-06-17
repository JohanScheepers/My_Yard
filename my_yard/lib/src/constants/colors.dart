import 'package:flutter/material.dart';

// Define your app's primary and secondary colors.
// For a more robust solution, consider using a seed color to generate
// a full ColorScheme.

const Color kPrimarySeedColor = Colors.green; // Example primary seed color
const Color kSecondarySeedColor =
    Colors.blueAccent; // Example secondary seed color

// Light Theme Colors
final ColorScheme kLightColorScheme = ColorScheme.fromSeed(
  seedColor: kPrimarySeedColor,
  secondary: kSecondarySeedColor,
  brightness: Brightness.light,
);

// Dark Theme Colors
final ColorScheme kDarkColorScheme = ColorScheme.fromSeed(
  seedColor: kPrimarySeedColor,
  secondary: kSecondarySeedColor,
  brightness: Brightness.dark,
  // You can further customize dark theme specific colors here if needed
  // e.g., surface: Colors.grey[850],
);
