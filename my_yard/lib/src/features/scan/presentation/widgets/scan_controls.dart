// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_yard/src/constants/ui_constants.dart';
import 'package:my_yard/src/features/scan/application/scan_service.dart';

/// A widget for the Start/Stop scan button.
class ScanControls extends ConsumerWidget {
  const ScanControls({
    super.key,
    required this.isButtonEnabled,
    required this.isScanActive,
  });

  final bool isButtonEnabled;
  final bool isScanActive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: kButtonWidthMedium,
      child: ElevatedButton(
        onPressed: isButtonEnabled
            ? (isScanActive
                ? () => ref.read(scanServiceProvider.notifier).stopScan()
                : () => ref.read(scanServiceProvider.notifier).startScan())
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isScanActive ? Colors.red : Colors.green,
          foregroundColor: isScanActive
              ? Theme.of(context).colorScheme.onError
              : Colors.white,
        ),
        child: Text(isScanActive ? 'Stop Scan' : 'Start Scan'),
      ),
    );
  }
}
