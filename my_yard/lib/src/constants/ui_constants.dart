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

// --- Padding Constants ---
const EdgeInsets kPagePadding = EdgeInsets.all(kSpaceMedium);
const EdgeInsets kVerticalPaddingMedium = EdgeInsets.symmetric(vertical: kSpaceMedium);
const EdgeInsets kHorizontalPaddingMedium = EdgeInsets.symmetric(horizontal: kSpaceMedium);
const EdgeInsets kSettingsSectionTitlePadding = EdgeInsets.fromLTRB(kSpaceMedium, kSpaceMedium, kSpaceMedium, 0);
const EdgeInsets kCardPadding = EdgeInsets.all(kSpaceSmall); // For internal card padding

// --- Spacer Widgets ---
const SizedBox kVerticalSpacerXXSmall = SizedBox(height: kSpaceXXSmall);
const SizedBox kVerticalSpacerXSmall = SizedBox(height: kSpaceXSmall);
const SizedBox kVerticalSpacerSmall = SizedBox(height: kSpaceSmall);
const SizedBox kVerticalSpacerMedium = SizedBox(height: kSpaceMedium);
const SizedBox kVerticalSpacerLarge = SizedBox(height: kSpaceLarge);
const SizedBox kVerticalSpacerXLarge = SizedBox(height: kSpaceXLarge);
const SizedBox kVerticalSpacerXXLarge = SizedBox(height: kSpaceXXLarge);

const SizedBox kHorizontalSpacerXSmall = SizedBox(width: kSpaceXSmall);
const SizedBox kHorizontalSpacerSmall = SizedBox(width: kSpaceSmall);
const SizedBox kHorizontalSpacerMedium = SizedBox(width: kSpaceMedium);
const SizedBox kHorizontalSpacerLarge = SizedBox(width: kSpaceLarge);
const SizedBox kHorizontalSpacerXLarge = SizedBox(width: kSpaceXLarge);

// --- Button Constants ---
const Size kButtonMinSize = Size(220, 48);

// --- Card Constants ---
const double kCardElevationDefault = 2.0;
const int kCardOverlayAlpha = 50; // Alpha value for semi-transparent card overlay (0-255)

// --- Circular Progress Indicator Constants ---
const double kCircularProgressStrokeWidth = 3.0;

// --- Animation Durations ---
const Duration kAnimationDurationShort = Duration(milliseconds: 150);
const Duration kAnimationDurationMedium = Duration(milliseconds: 300);
const Duration kAnimationDurationLong = Duration(milliseconds: 500);

// --- Divider Constants ---
const double kDividerThickness = 1.0;
const double kDividerIndent = 16.0;


// --- Layout Breakpoints ---
const double kWideLayoutBreakpoint = 600.0;






// Timeouts
const int kPingTimeoutDuration =  1;
const Duration kHttpRequestTimeoutDuration = Duration(seconds: 5); // New constant for HTTP timeout