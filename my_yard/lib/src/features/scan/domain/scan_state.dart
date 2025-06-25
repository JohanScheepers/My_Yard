import 'package:my_yard/src/features/scan/domain/ping_result.dart';

/// Represents the overall state of the network scan.
class ScanState {
  final int successfulPings;
  final int failedPings;
  final String? currentIp;
  final int scannedCount;
  final int totalToScan;
  final List<PingResult> results;

  const ScanState({
    this.successfulPings = 0,
    this.failedPings = 0,
    this.currentIp,
    this.scannedCount = 0,
    this.totalToScan = 254,
    this.results = const [],
  });

  /// Creates a copy of the state with updated values.
  ScanState copyWith({
    int? successfulPings,
    int? failedPings,
    String? currentIp,
    int? scannedCount,
    int? totalToScan,
    List<PingResult>? results,
  }) {
    return ScanState(
      successfulPings: successfulPings ?? this.successfulPings,
      failedPings: failedPings ?? this.failedPings,
      currentIp: currentIp ?? this.currentIp,
      scannedCount: scannedCount ?? this.scannedCount,
      totalToScan: totalToScan ?? this.totalToScan,
      results: results ?? this.results,
    );
  }
}
