// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard

import 'package:flutter/material.dart';
import 'package:my_yard/src/features/scan/domain/ping_result.dart';

/// Displays a list of ping results.
class ScanResultsList extends StatelessWidget {
  const ScanResultsList({
    super.key,
    required this.results,
    required this.isShrunk,
    required this.onDeviceTap,
  });

  final List<PingResult> results;
  final bool isShrunk;
  final Function(String ip) onDeviceTap; // Callback for device tap

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const Center(
        child: Text('No devices found yet. Start a scan to begin.'),
      );
    }
    return ListView.builder(
      shrinkWrap: isShrunk,
      physics: isShrunk ? const NeverScrollableScrollPhysics() : null,
      itemCount: results.length,
      itemBuilder: (context, index) {
        final PingResult result = results[index];
        return ListTile(
          leading: const Icon(Icons.lan_outlined),
          title: Text(result.ip), // Display the IP address
          trailing: Text('${result.latency.inMilliseconds} ms'),
          onTap: () => onDeviceTap(result.ip), // Use the callback
        );
      },
    );
  }
}
