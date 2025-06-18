// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard

import 'package:flutter/material.dart';

// It's good practice to define a base text theme and then customize it.
// You can use GoogleFonts package for a wider variety of fonts.

const TextTheme kAppTextTheme = TextTheme(
  displayLarge: TextStyle(fontSize: 57.0, fontWeight: FontWeight.bold),
  displayMedium: TextStyle(fontSize: 45.0, fontWeight: FontWeight.bold),
  displaySmall: TextStyle(fontSize: 36.0, fontWeight: FontWeight.bold),
  headlineLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
  headlineMedium: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
  headlineSmall: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700),
  titleLarge: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w700),
  titleMedium: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700),
  titleSmall: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
  labelLarge: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w700),
  labelMedium: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w500),
  labelSmall: TextStyle(fontSize: 11.0, fontWeight: FontWeight.w500),
  bodyLarge: TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal),
  bodyMedium: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal),
  bodySmall: TextStyle(fontSize: 12.0, fontWeight: FontWeight.normal),
);
