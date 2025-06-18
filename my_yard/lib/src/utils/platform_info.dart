// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// A utility class to determine the current operating system.
///
/// Provides boolean flags for common platforms and the operating system name.
class OperatingSys {


  /// Returns the name of the operating system.
  ///
  /// Possible values are 'android', 'ios', 'linux', 'macos', 'windows',
  /// and 'fuchsia'. Returns 'web' if running on the web platform.
  /// Note: Accessing Platform.operatingSystem directly will throw on web.
  static String get operatingSystem {
    if (kIsWeb) {
      return 'web';
    }
    return Platform.operatingSystem;
  }

  /// Whether the operating system is Android.
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;

  /// Whether the operating system is iOS.
  static bool get isIOS => !kIsWeb && Platform.isIOS;

  /// Whether the operating system is Linux.
  static bool get isLinux => !kIsWeb && Platform.isLinux;

  /// Whether the operating system is macOS.
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;

  /// Whether the operating system is Windows.
  static bool get isWindows => !kIsWeb && Platform.isWindows;

  /// Whether the operating system is Fuchsia.
  static bool get isFuchsia => !kIsWeb && Platform.isFuchsia;

  /// Whether the application is running on the web platform.
  static bool get isWeb => kIsWeb;

  /// Determines the platform using a switch statement on the operating system name.
  ///
  /// This can be useful for executing platform-specific logic.
  static void determinePlatformWithSwitch() {
    switch (operatingSystem) {
      case 'android':
        print('Running on Android');
        break;
      case 'ios':
        print('Running on iOS');
        break;
      case 'web':
        print('Running on Web');
        break;
      // Add cases for 'linux', 'macos', 'windows', 'fuchsia' as needed
      default:
        print('Running on an unknown platform: $operatingSystem');
    }
  }
}
