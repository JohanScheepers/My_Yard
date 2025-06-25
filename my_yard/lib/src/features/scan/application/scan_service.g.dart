// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$scanServiceHash() => r'727b34f31930301ae6014e6ac08dcdaba60354f6';

/// A service class for scanning the local network for devices.
///
/// This class uses Riverpod's AsyncNotifier to manage the state of the scan,
/// including progress, successful pings, failed pings, and a list of results.
/// It also provides a mechanism to start and stop the scan.
///
/// Copied from [ScanService].
@ProviderFor(ScanService)
final scanServiceProvider =
    AutoDisposeAsyncNotifierProvider<ScanService, ScanState>.internal(
  ScanService.new,
  name: r'scanServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$scanServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ScanService = AutoDisposeAsyncNotifier<ScanState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
