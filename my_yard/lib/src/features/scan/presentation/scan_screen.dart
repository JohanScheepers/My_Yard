// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard

import 'dart:convert'; // Added for jsonEncode/decode
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_yard/src/constants/ui_constants.dart';
import 'package:my_yard/src/features/scan/presentation/widgets/add_device_dialog.dart';
import 'package:my_yard/src/features/scan/presentation/widgets/connecting_device_dialog.dart';
import 'package:my_yard/src/features/scan/presentation/widgets/error_dialog.dart';

import 'package:my_yard/src/features/scan/presentation/widgets/scan_narrow_layout.dart';
import 'package:my_yard/src/features/scan/presentation/widgets/scan_wide_layout.dart';

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
      
      body: LayoutBuilder(
        builder: (context, constraints) {
          Widget currentLayout;
          Key layoutKey;
          if (constraints.maxWidth > kMobileBreakpointMax) {
            currentLayout = ScanWideLayout(
              textTheme: textTheme,
              scanState: scanState,
              scanAsyncValue: scanAsyncValue,
              isScanActive: isScanActive,
              isButtonEnabled: isButtonEnabled,
              onDeviceTap: _onDeviceTap,
            );
            layoutKey = const ValueKey('wideLayout');
          } else {
            currentLayout = ScanNarrowLayout(
              textTheme: textTheme,
              scanState: scanState,
              scanAsyncValue: scanAsyncValue,
              isScanActive: isScanActive,
              isButtonEnabled: isButtonEnabled,
              onDeviceTap: _onDeviceTap,
            );
            layoutKey = const ValueKey('narrowLayout');
          }
          // Wrap the current layout in an AnimatedSwitcher for smooth transitions
          return AnimatedSwitcher(
            duration:
                kAnimationDurationLong, // Use the defined animation duration
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: SizedBox.expand(
              key: layoutKey,
              child: currentLayout,
            ),
          );
        },
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
      if (mounted) { // Changed from context.mounted to mounted
        Navigator.of(context).pop(); // Pop the ConnectingDeviceDialog
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Ensure the device firmware is updated and sends a unique ID.
        if (data['id'] == null) {
          if (mounted) { // Changed from context.mounted to mounted
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

        if (mounted) { // Changed from context.mounted to mounted
          showDialog(
            context: context,
            builder: (dialogContext) => AddDeviceDialog(device: device),
          );
        }
      } else {
        // Handle HTTP error
        if (mounted) { // Changed from context.mounted to mounted
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
      if (mounted && Navigator.of(context).canPop()) { // Changed from context.mounted to mounted
        Navigator.of(context).pop();
      }
      // Handle other errors (e.g., network issues, JSON parsing errors)
      if (mounted) { // Changed from context.mounted to mounted
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
