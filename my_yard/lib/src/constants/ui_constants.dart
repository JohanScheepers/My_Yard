// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard

import 'package:flutter/material.dart';

// Standard Spacing
const double kSpaceXXSmall = 2.0;
const double kSpaceXSmall = 4.0;
const double kSpaceSmall = 8.0;
const double kSpaceMedium = 16.0;
const double kSpaceLarge = 24.0;
const double kSpaceXLarge = 32.0;
const double kSpaceXXLarge = 48.0;

// Standard Padding
const EdgeInsets kPagePadding = EdgeInsets.all(kSpaceMedium);
const EdgeInsets kCardPadding = EdgeInsets.all(kSpaceSmall);
const EdgeInsets kHorizontalPaddingSmall =
    EdgeInsets.symmetric(horizontal: kSpaceSmall);
const EdgeInsets kHorizontalPaddingMedium =
    EdgeInsets.symmetric(horizontal: kSpaceMedium);
const EdgeInsets kVerticalPaddingSmall =
    EdgeInsets.symmetric(vertical: kSpaceSmall);
const EdgeInsets kVerticalPaddingMedium =
    EdgeInsets.symmetric(vertical: kSpaceMedium);

// Standard Border Radius
final BorderRadius kBorderRadiusSmall = BorderRadius.circular(4.0);
final BorderRadius kBorderRadiusMedium = BorderRadius.circular(8.0);
final BorderRadius kBorderRadiusLarge = BorderRadius.circular(12.0);
final BorderRadius kCircleBorderRadius =
    BorderRadius.circular(100.0); // For circular elements

// Reusable SizedBox Widgets
const SizedBox kVerticalSpacerXXSmall = SizedBox(height: kSpaceXXSmall);
const SizedBox kVerticalSpacerXSmall = SizedBox(height: kSpaceXSmall);
const SizedBox kVerticalSpacerSmall = SizedBox(height: kSpaceSmall);
const SizedBox kVerticalSpacerMedium = SizedBox(height: kSpaceMedium);
const SizedBox kVerticalSpacerLarge = SizedBox(height: kSpaceLarge);
const SizedBox kVerticalSpacerXLarge = SizedBox(height: kSpaceXLarge);
const SizedBox kVerticalSpacerXXLarge = SizedBox(height: kSpaceXXLarge);

const SizedBox kHorizontalSpacerSmall = SizedBox(width: kSpaceSmall);
const SizedBox kHorizontalSpacerMedium = SizedBox(width: kSpaceMedium);
const SizedBox kHorizontalSpacerLarge = SizedBox(width: kSpaceLarge);

// lib/src/constants/ui_constants.dart
// ... other constants
const double kWideLayoutBreakpoint = 600.0;
// ...
