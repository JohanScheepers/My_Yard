// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$themeNotifierHash() => r'5e0495da8ca51705d71501e7697fc0fee17ca9b9';

/// Manages the application's theme mode and persists it using SharedPreferences.
///
/// Copied from [ThemeNotifier].
@ProviderFor(ThemeNotifier)
final themeNotifierProvider =
    AutoDisposeAsyncNotifierProvider<ThemeNotifier, AppThemeMode>.internal(
  ThemeNotifier.new,
  name: r'themeNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$themeNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ThemeNotifier = AutoDisposeAsyncNotifier<AppThemeMode>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
