// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unit_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$unitNotifierHash() => r'5885716cf661de0f033557e54f7890c7d19382d0';

/// Manages the application's unit system preference and persists it using SharedPreferences.
///
/// Copied from [UnitNotifier].
@ProviderFor(UnitNotifier)
final unitNotifierProvider =
    AutoDisposeAsyncNotifierProvider<UnitNotifier, UnitSystem>.internal(
  UnitNotifier.new,
  name: r'unitNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$unitNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UnitNotifier = AutoDisposeAsyncNotifier<UnitSystem>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
