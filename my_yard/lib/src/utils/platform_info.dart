import 'dart:io' show Platform;

/// A utility class to determine the current operating system.
///
/// Provides boolean flags for common platforms and the operating system name.
class PlatformInfo {
  const PlatformInfo._(); // Private constructor to prevent instantiation

  /// Returns the name of the operating system.
  ///
  /// Possible values are 'android', 'ios', 'linux', 'macos', 'windows',
  /// and 'fuchsia'.
  static String get operatingSystem => Platform.operatingSystem;

  /// Whether the operating system is Android.
  static bool get isAndroid => Platform.isAndroid;

  /// Whether the operating system is iOS.
  static bool get isIOS => Platform.isIOS;

  /// Whether the operating system is Linux.
  static bool get isLinux => Platform.isLinux;

  /// Whether the operating system is macOS.
  static bool get isMacOS => Platform.isMacOS;

  /// Whether the operating system is Windows.
  static bool get isWindows => Platform.isWindows;

  /// Whether the operating system is Fuchsia.
  static bool get isFuchsia => Platform.isFuchsia;

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
      // Add cases for 'linux', 'macos', 'windows', 'fuchsia' as needed
      default:
        print('Running on an unknown platform: $operatingSystem');
    }
  }
}
