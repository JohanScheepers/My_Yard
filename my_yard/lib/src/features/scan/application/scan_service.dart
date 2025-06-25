import 'dart:async';

import 'package:dart_ping/dart_ping.dart';
import 'package:http/http.dart' as http;
import 'package:my_yard/src/features/scan/domain/ping_result.dart';
import 'package:my_yard/src/features/scan/domain/scan_state.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'scan_service.g.dart';

/// A service class for scanning the local network for devices.
///
/// This class uses Riverpod's AsyncNotifier to manage the state of the scan,
/// including progress, successful pings, failed pings, and a list of results.
/// It also provides a mechanism to start and stop the scan.
@riverpod
class ScanService extends _$ScanService {
  // A completer to signal cancellation of the scan.
  // When complete, the scan loop should stop.
  Completer<void>? _cancelCompleter;

  // Keep track of the current Ping instance to stop it if needed.
  Ping? _currentPinger;

  @override
  Future<ScanState> build() async {
    // When the provider is destroyed, make sure to cancel any ongoing scan.
    ref.onDispose(() {
      if (_cancelCompleter != null && !_cancelCompleter!.isCompleted) {
        _cancelCompleter!.complete();
      }
      _currentPinger?.stop();
      _cancelCompleter = null; // Ensure it's nulled on dispose
    });
    // Return initial state. The UI will show the "Start Scan" button.
    return const ScanState();
  }

  /// Starts scanning the local network for devices.
  Future<void> startScan() async {
    // If a scan is already running, do nothing.
    // This prevents multiple concurrent scans.
    if (_cancelCompleter != null && !_cancelCompleter!.isCompleted) {
      return;
    }

    final Completer<void> currentScanCompleter = Completer<void>();
    _cancelCompleter = currentScanCompleter; // Assign to class member for external access
    // Set state to loading before we start
    state = const AsyncLoading();

    // Use guard to handle exceptions during the async operation
    state = await AsyncValue.guard(() async {
      final networkInfo = NetworkInfo();
      final ip = await networkInfo.getWifiIP();

      if (ip == null) {
        throw Exception(
            'Could not get Wi-Fi IP. Ensure you are connected to a Wi-Fi network.');
      }

      final subnet = ip.substring(0, ip.lastIndexOf('.'));
      var currentScanState = const ScanState();

      // Set initial data state so UI can show progress
      state = AsyncData(currentScanState);

      try {
        for (int i = 1; i < 255; i++) {
          // Check for cancellation request before each ping
          if (currentScanCompleter.isCompleted) { // Use the local completer instance
            print('Scan cancelled by user.');
            break; // Exit the loop
          }

          final host = '$subnet.$i';

          // Update the UI with the IP we are currently pinging
          currentScanState = currentScanState.copyWith(currentIp: host);
          state = AsyncData(currentScanState);

          _currentPinger = Ping(host, count: 1, timeout: 1);

          try {
            // dart_ping's stream will complete with a PingData object
            // that contains either a response or an error.
            final PingData result = await _currentPinger!.stream.first;

            if (result.response != null) {
              // Successful ping
              final newResults = List<PingResult>.from(currentScanState.results)
                ..add(PingResult(ip: host, latency: result.response!.time!));

              currentScanState = currentScanState.copyWith(
                successfulPings: currentScanState.successfulPings + 1,
                results: newResults,
              );
            }
          } catch (e) {
            // Catch exceptions from the ping stream itself (e.g., host not reachable)
            // This is where failed pings are implicitly handled if no response is received.
            // We increment failedPings in the finally block if no success was recorded.
          } finally {
            // This block runs whether the ping succeeded or failed.
            // Check if the current host was successfully added to results in this iteration
            final isSuccess = currentScanState.results.any((r) => r.ip == host);
            currentScanState = currentScanState.copyWith(
              failedPings: isSuccess ? null : currentScanState.failedPings + 1, // Only increment if not successful
              scannedCount: currentScanState.scannedCount + 1,
            );
          }

          // Update the state after each ping attempt
          state = AsyncData(currentScanState);
        }
      } finally {
        // Ensure the current pinger is stopped and completer is marked complete
        _currentPinger?.stop();
        _currentPinger = null;
        if (!currentScanCompleter.isCompleted) { // Use the local completer instance
          currentScanCompleter.complete(); // Mark as completed if loop finished naturally
        }
        // Always null out the class member completer after the scan process
        // has finished (either naturally or by cancellation). This prevents
        // any further attempts to complete this specific completer instance.
        _cancelCompleter = null;
      }

      // Final state update to clear the "currently pinging" IP
      return currentScanState.copyWith(currentIp: 'Scan Complete');
    });
  }

  /// Stops the currently running scan.
  void stopScan() {
    if (_cancelCompleter != null && !_cancelCompleter!.isCompleted) {
      _cancelCompleter!.complete(); // Signal the scan loop to stop
      _currentPinger?.stop(); // Stop the active ping process immediately
      _currentPinger = null; // Clear the reference
      _cancelCompleter = null; // Clear the completer after it's used

      // Update the state to show that the scan was stopped.
      if (state.hasValue) {
        state = AsyncData(state.value!.copyWith(currentIp: 'Scan Stopped'));
      }
    }
  }

  /// Sends an HTTP POST request to the specified IP with a JSON body.
  /// Sends an HTTP GET request to the specified IP to retrieve device information.
  /// Throws an exception if the request fails.
  Future<http.Response> sendDeviceRequest(String ip) async {
    // The device's server (my_tank_control_basic.ino) listens for GET requests at the root path '/'.
    final url = Uri.parse('http://$ip/');
    try {
      final response = await http.get(
          url, // Use the root URL
          headers: {'Content-Type': 'application/json'}, // Still good practice to specify expected content type
      );
      return response;
    } catch (e) {
      rethrow; // Re-throw the error to be handled by the caller (ScanScreen)
    }
  }
}
