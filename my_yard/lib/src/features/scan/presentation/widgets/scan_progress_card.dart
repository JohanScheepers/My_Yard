// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard

import 'package:flutter/material.dart';
import 'package:my_yard/src/constants/ui_constants.dart';
import 'package:my_yard/src/features/scan/domain/scan_state.dart';

/// A widget displaying the current scan progress.
class ScanProgressCard extends StatelessWidget {
  const ScanProgressCard({
    super.key,
    required this.textTheme,
    required this.scanState,
    required this.isScanActive,
  });

  final TextTheme textTheme;
  final ScanState scanState;
  final bool isScanActive;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(kSpaceMedium),
        child: Column(
          children: [
            Text('Scan Progress', style: textTheme.titleLarge),
            const SizedBox(height: kSpaceSmall),
            LinearProgressIndicator(
              value: scanState.totalToScan > 0
                  ? scanState.scannedCount / scanState.totalToScan
                  : 0.0,
              minHeight: kLinearProgressMinHeight,
              color: isScanActive ? Colors.red : Colors.green,
            ),
            const SizedBox(height: kSpaceMedium),
            Text('Status: ${scanState.currentIp ?? "Idle"}'),
            const SizedBox(height: kSpaceSmall),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Text('Found: ${scanState.successfulPings}',
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis)),
                Expanded(
                    child: Text('Failed: ${scanState.failedPings}',
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis)),
                Expanded(
                    child: Text(
                        'Scanned: ${scanState.scannedCount}/${scanState.totalToScan}',
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
