// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard

import 'dart:convert'; // Added for jsonEncode/decode
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_yard/src/constants/ui_constants.dart';
import 'package:my_yard/src/features/scan/presentation/widgets/add_device_dialog.dart';
import 'package:my_yard/src/features/scan/presentation/widgets/connecting_device_dialog.dart';
import 'package:my_yard/src/features/scan/presentation/widgets/error_dialog.dart';
import 'package:my_yard/src/features/scan/presentation/widgets/scan_controls.dart';
import 'package:my_yard/src/features/scan/presentation/widgets/scan_progress_card.dart';
import 'package:my_yard/src/features/scan/presentation/widgets/scan_results_list.dart';
import 'package:my_yard/src/features/device/domain/device.dart'; // Added for Device model
import 'package:my_yard/src/features/scan/application/scan_service.dart';

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
    final scanState = scanAsyncValue.valueOrNull ?? const ScanState();

    // Determine if the scan is actively running
    final bool isScanActive = scanState.currentIp != null &&
        scanState.currentIp != 'Scan Complete' &&
        scanState.currentIp != 'Scan Stopped';

    // Determine if the button should be enabled
    final bool isButtonEnabled = !scanAsyncValue.hasError &&
        !(scanAsyncValue.isLoading && !isScanActive);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Scan'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > kMobileBreakpointMax) {
            return _buildWideLayout(context, textTheme, scanState,
                scanAsyncValue, isScanActive, isButtonEnabled);
          } else {
            return _buildNarrowLayout(context, textTheme, scanState,
                scanAsyncValue, isScanActive, isButtonEnabled);
          }
        },
      ),
    );
  }

  /// Builds the layout for narrow screens (e.g., mobile phones).
  Widget _buildNarrowLayout(
      BuildContext context,
      TextTheme textTheme,
      ScanState scanState,
      AsyncValue<ScanState> scanAsyncValue,
      bool isScanActive,
      bool isButtonEnabled) {
    return Padding(
      padding: kPagePadding,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ScanControls(
                isButtonEnabled: isButtonEnabled, isScanActive: isScanActive),
            const SizedBox(height: kSpaceMedium),
            ScanProgressCard(
                textTheme: textTheme,
                scanState: scanState,
                isScanActive: isScanActive),
            const SizedBox(height: kSpaceMedium),
            Text('Found Devices', style: textTheme.titleLarge),
            const Divider(),
            if (scanAsyncValue.hasError && !scanAsyncValue.isLoading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: kSpaceMedium),
                  child: Text(
                    'Error: ${scanAsyncValue.error}',
                    style: textTheme.bodyMedium
                        ?.copyWith(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              ),
            ScanResultsList(
                results: scanState.results,
                isShrunk: true,
                onDeviceTap: _onDeviceTap),
          ],
        ),
      ),
    );
  }

  /// Builds the layout for wide screens (e.g., tablets, desktops).
  Widget _buildWideLayout(
      BuildContext context,
      TextTheme textTheme,
      ScanState scanState,
      AsyncValue<ScanState> scanAsyncValue,
      bool isScanActive,
      bool isButtonEnabled) {
    return Padding(
      padding: kPagePadding,
      child: Column(
        children: [
          ScanControls(
              isButtonEnabled: isButtonEnabled, isScanActive: isScanActive),
          const SizedBox(height: kSpaceMedium),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    child: ScanProgressCard(
                        textTheme: textTheme,
                        scanState: scanState,
                        isScanActive: isScanActive),
                  ),
                ),
                const SizedBox(width: kSpaceMedium),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Found Devices', style: textTheme.titleLarge),
                      const Divider(),
                      if (scanAsyncValue.hasError && !scanAsyncValue.isLoading)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: kSpaceMedium),
                            child: Text(
                              'Error: ${scanAsyncValue.error}',
                              style: textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.error),
                            ),
                          ),
                        ),
                      Expanded(
                        child: ScanResultsList(
                            results: scanState.results,
                            isShrunk: false,
                            onDeviceTap: _onDeviceTap),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // New method to handle device tap
  Future<void> _onDeviceTap(String ip) async {
    // Show a loading indicator while waiting for the response
    showDialog(
      context: context,
      barrierDismissible: false, // User must wait for response
      builder: (BuildContext dialogContext) => const ConnectingDeviceDialog(),
    );

    try {
      final response = await ref
          .read(scanServiceProvider.notifier)
          .sendDeviceRequest(
              ip); // No body needed for a GET request to the root

      // Dismiss the loading indicator
      if (context.mounted) {
        Navigator.of(context).pop(); // Pop the ConnectingDeviceDialog
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Ensure the device firmware is updated and sends a unique ID.
        if (data['id'] == null) {
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (dialogContext) => const ErrorDialog(
                message:
                    'Device response is missing a unique ID. Please update the device firmware.',
              ),
            );
          }
          return;
        }

        final device = Device.fromJson(data);

        if (context.mounted) {
          showDialog(
            context: context,
            builder: (dialogContext) => AddDeviceDialog(device: device),
          );
        }
      } else {
        // Handle HTTP error
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (dialogContext) => ErrorDialog(
              message: 'HTTP Error: ${response.statusCode}\n${response.body}',
            ),
          );
        }
      }
    } catch (e) {
      // Dismiss the loading indicator if an error occurred before it was dismissed
      // Check mounted before accessing context for canPop and pop
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      // Handle other errors (e.g., network issues, JSON parsing errors)
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (dialogContext) => ErrorDialog(
            message: 'Error connecting to device: $e',
          ),
        );
      }
    }
  }
}
