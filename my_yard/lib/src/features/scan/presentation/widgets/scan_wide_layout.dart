// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_yard/src/constants/ui_constants.dart';
import 'package:my_yard/src/features/scan/domain/scan_state.dart';
import 'package:my_yard/src/features/scan/presentation/widgets/scan_controls.dart';
import 'package:my_yard/src/features/scan/presentation/widgets/scan_progress_card.dart';
import 'package:my_yard/src/features/scan/presentation/widgets/scan_results_list.dart';

/// Builds the layout for wide screens (e.g., tablets, desktops) for the ScanScreen.
class ScanWideLayout extends StatelessWidget {
  const ScanWideLayout({
    super.key,
    required this.textTheme,
    required this.scanState,
    required this.scanAsyncValue,
    required this.isScanActive,
    required this.isButtonEnabled,
    required this.onDeviceTap,
  });

  final TextTheme textTheme;
  final ScanState scanState;
  final AsyncValue<ScanState> scanAsyncValue;
  final bool isScanActive;
  final bool isButtonEnabled;
  final Function(String ip) onDeviceTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kPagePadding,
      child: Expanded(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ScanControls(
                        isButtonEnabled: isButtonEnabled,
                        isScanActive: isScanActive),
                    ScanProgressCard(
                        textTheme: textTheme,
                        scanState: scanState,
                        isScanActive: isScanActive),
                  ],
                ),
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
                        onDeviceTap: onDeviceTap),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
