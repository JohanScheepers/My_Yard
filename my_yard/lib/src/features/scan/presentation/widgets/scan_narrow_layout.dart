// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_yard/src/constants/ui_constants.dart';
import 'package:my_yard/src/features/scan/domain/scan_state.dart';
import 'package:my_yard/src/features/scan/presentation/widgets/scan_controls.dart';
import 'package:my_yard/src/features/scan/presentation/widgets/scan_progress_card.dart';
import 'package:my_yard/src/features/scan/presentation/widgets/scan_results_list.dart';

/// Builds the layout for narrow screens (e.g., mobile phones) for the ScanScreen.
class ScanNarrowLayout extends StatelessWidget {
  const ScanNarrowLayout({
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
                onDeviceTap: onDeviceTap),
          ],
        ),
      ),
    );
  }
}
