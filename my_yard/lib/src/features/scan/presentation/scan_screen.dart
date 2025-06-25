// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard

import 'dart:convert'; // Added for jsonEncode/decode
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_yard/src/constants/ui_constants.dart';
import 'package:my_yard/src/features/device/application/device_list_notifier.dart'; // Added for device list management
import 'package:my_yard/src/features/device/domain/device.dart'; // Added for Device model
import 'package:my_yard/src/features/scan/application/scan_service.dart';
import 'package:my_yard/src/features/scan/domain/ping_result.dart'; // Import the PingResult model
import 'package:my_yard/src/features/scan/domain/scan_state.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  static const String routeName = '/scan';

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  @override
  Widget build(BuildContext context) {
    final scanAsyncValue = ref.watch(scanServiceProvider);
    final textTheme = Theme.of(context).textTheme;

    // We can get the current state data, even during loading/error for a better UX
    final scanState = scanAsyncValue.valueOrNull ?? const ScanState();

    // Determine if the scan is actively running (currentIp is an actual IP being pinged)
    final bool isScanActive = scanState.currentIp != null &&
        scanState.currentIp != 'Scan Complete' &&
        scanState.currentIp != 'Scan Stopped';

    final isScanComplete = scanState.currentIp == 'Scan Complete' ||
        scanState.currentIp == 'Scan Stopped';

    // Determine if the button should be enabled. It's disabled if there's an error
    // or if the service is in a transient loading state (e.g., initial network info lookup)
    // and not actively scanning.
    final bool isButtonEnabled = !scanAsyncValue.hasError &&
        !(scanAsyncValue.isLoading && !isScanActive);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Scan'),
      ),
      body: Padding(
        padding: kPagePadding,
        child: SingleChildScrollView(
          // Wrap the Column in SingleChildScrollView
          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: isButtonEnabled
                      ? (isScanActive
                          ? () =>
                              ref.read(scanServiceProvider.notifier).stopScan()
                          : () => ref
                              .read(scanServiceProvider.notifier)
                              .startScan())
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isScanActive
                        ? Colors.red // Red for Stop
                        : Colors.green, // Green for Start
                    foregroundColor: isScanActive
                        ? Theme.of(context)
                            .colorScheme
                            .onError // Text color for red  button
                        : Colors.white, // Text color for green button
                  ), // Use default style for Start Scan
                  child: Text(isScanActive ? 'Stop Scan' : 'Start Scan'),
                ),
              ),
              const SizedBox(height: kSpaceMedium),
              // Show progress card if we are scanning or have scanned before
              //if (scanAsyncValue.isLoading || scanState.scannedCount > 0)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(kSpaceMedium),
                  child: Column(
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Scan Progress', style: textTheme.titleLarge),
                      const SizedBox(height: kSpaceSmall),
                      //if (scanState.totalToScan > 0 &&
                      //!isScanComplete) // Only show progress bar if not complete
                      LinearProgressIndicator(
                        value: scanState.scannedCount / scanState.totalToScan,
                        minHeight: 10,
                        color: isScanActive
                            ? Colors.red // Red for Stop
                            : Colors.green,
                      ),
                      const SizedBox(height: kSpaceMedium),
                      Text('Status: ${scanState.currentIp ?? "Idle"}'),
                      const SizedBox(height: kSpaceSmall),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text('Successful: ${scanState.successfulPings}',
                              textAlign: TextAlign.center,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis),
                          Text('Failed: ${scanState.failedPings}',
                              textAlign: TextAlign.center,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis),
                          Text(
                              'Scanned: ${scanState.scannedCount}/${scanState.totalToScan}',
                              textAlign: TextAlign.center,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: kSpaceMedium),
              Text('Found Devices', style: textTheme.titleLarge),
              const Divider(),
              // Handle error state separately
              if (scanAsyncValue.hasError && !scanAsyncValue.isLoading)
                Center(
                  child: Text(
                    'Error: ${scanAsyncValue.error}',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              // The ListView.builder now needs shrinkWrap and NeverScrollableScrollPhysics
              // because its parent (SingleChildScrollView) provides infinite height.
              _buildResultsList(scanState.results),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsList(List<PingResult> results) {
    if (results.isEmpty) {
      return const Center(
        child: Text('No devices found yet. Start a scan to begin.'),
      );
    }
    return ListView.builder(
      shrinkWrap: true, // Important: Make ListView take only needed space
      physics:
          const NeverScrollableScrollPhysics(), // Important: Let SingleChildScrollView handle scrolling
      itemCount: results.length,
      itemBuilder: (context, index) {
        final PingResult result = results[index];
        return ListTile(
          leading: const Icon(Icons.lan_outlined),
          title: Text(result.ip), // Display the IP address
          trailing: Text('${result.latency.inMilliseconds} ms'),
          onTap: () => _onDeviceTap(ip: result.ip),
        );
      },
    );
  }

  // New method to handle device tap
  Future<void> _onDeviceTap({required String ip}) async {
    // Show a loading indicator while waiting for the response
    showDialog(
      context: context,
      barrierDismissible: false, // User must wait for response
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: kSpaceMedium),
              Text('Connecting to device...'),
            ],
          ),
        );
      },
    );

    try {
      final response = await ref
          .read(scanServiceProvider.notifier)
          .sendDeviceRequest(
              ip); // No body needed for a GET request to the root

      // Dismiss the loading indicator
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Ensure the device firmware is updated and sends a unique ID.
        if (data['id'] == null) {
          if (mounted) {
            _showErrorDialog(
                'Device response is missing a unique ID. Please update the device firmware.');
          }
          return;
        }

        final device = Device.fromJson(data);

        if (mounted) {
          _showAddDeviceDialog(device);
        }
      } else {
        // Handle HTTP error
        if (mounted) {
          _showErrorDialog(
              'HTTP Error: ${response.statusCode}\n${response.body}');
        }
      }
    } catch (e) {
      // Dismiss the loading indicator if an error occurred before it was dismissed
      // Check mounted before accessing context for canPop and pop
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      // Handle other errors (e.g., network issues, JSON parsing errors)
      if (mounted) {
        _showErrorDialog('Error connecting to device: $e');
      }
    }
  }

  // New method to display device information and offer to add it
  void _showAddDeviceDialog(Device device) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Found Device'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('ID: ${device.id}'),
                Text('IP: ${device.ip}'),
                Text('Type: ${device.nodeType}'),
                Text('Current Time: ${device.currentTime ?? 'N/A'}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add Device'),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog first
                try {
                  await ref
                      .read(deviceListNotifierProvider.notifier)
                      .addDevice(device);
                  if (mounted) {
                    final theme = Theme.of(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.white, // White icon for success
                            ),
                            const SizedBox(width: kSpaceMedium),
                            Expanded(
                              child: Text(
                                'Device ${device.id} added.',
                                style: const TextStyle(color: Colors.white), // White text for success
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.green, // Green background for success
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              12.0), // A modern, rounded look
                        ),
                        duration: const Duration(seconds: 5), // Example: Display for 3 seconds
                        action: SnackBarAction(
                          label: 'UNDO',
                          textColor: theme.colorScheme.primary,
                          onPressed: () {
                            ref
                                .read(deviceListNotifierProvider.notifier)
                                .removeDevice(device.id);
                          },
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    _showErrorDialog(e.toString().replaceFirst('Exception: ', ''));
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  // New method to display error messages in a popup
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: SingleChildScrollView(child: Text(message)),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
