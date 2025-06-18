import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'dart:async'; // For StreamSubscription
import 'package:dart_ping/dart_ping.dart';
import 'dart:io'; // For InternetAddress

import 'package:my_yard/src/constants/ui_constants.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _isScanning = false;
  List<DiscoveredDevice> _discoveredDevices = [];
  String? _localIP;
  int _pingsSent = 0;
  int _successfulPings = 0;
  int _unsuccessfulPings = 0;
  String? _currentPingTargetIP;


  @override
  void initState() {
    super.initState();
    _getLocalIP();
  }

  Future<void> _getLocalIP() async {
    final networkInfo = NetworkInfo();
    try {
      _localIP = await networkInfo.getWifiIP();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint("Failed to get local IP: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get local IP: $e. Ensure Wi-Fi is connected and permissions are granted.')),
        );
      }
    }
  }

  void _startScan() async {
    if (_localIP == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not determine local IP. Ensure Wi-Fi is connected.')),
      );
      return;
    }

    setState(() {
      _isScanning = true;
      _discoveredDevices = [];
      _pingsSent = 0;
      _successfulPings = 0;
      _unsuccessfulPings = 0;
      _currentPingTargetIP = null;
    });

    final String subnet = _localIP!.substring(0, _localIP!.lastIndexOf('.'));

    for (int i = 1; i < 255; i++) {
      if (!_isScanning) break; 

      final String currentIP = '$subnet.$i';
      if (mounted) {
        setState(() => _currentPingTargetIP = currentIP);
      }


      _pingsSent++;
      final ping = Ping(currentIP, count: 1, timeout: 1); 
      bool deviceFoundThisAttempt = false;

      try {
        await for (final PingData event in ping.stream) {
          if (event.response != null && event.response!.ttl != null) {
            final pingTime = event.response!.time;
            String? hostname;
            try {
              final host = await InternetAddress(currentIP).reverse();
              hostname = host.host;
            } catch (e) {
              debugPrint('Could not resolve hostname for $currentIP: $e');
            }
            if (mounted) {
              if (!_discoveredDevices.any((d) => d.ip == currentIP)) {
                _discoveredDevices.add(DiscoveredDevice(
                  ip: currentIP,
                  hostname: hostname,
                  pingTime: pingTime,
                ));
                _discoveredDevices.sort((a, b) => _ipToComparable(a.ip).compareTo(_ipToComparable(b.ip)));
                _successfulPings++;
                deviceFoundThisAttempt = true;
              }
            }
            debugPrint('Found device: $currentIP ${hostname != null && hostname != currentIP ? "($hostname)" : ""} in ${pingTime?.inMilliseconds}ms');
            break; 
          } else if (event.error != null) {
            debugPrint('Ping error for $currentIP: ${event.error}');
            break; 
          }
        }
      } catch (e) {
        debugPrint('Error pinging $currentIP: $e');
      }

      if (!deviceFoundThisAttempt) {
        _unsuccessfulPings++;
      }

      if (mounted) {
        setState(() {});
      }
    }
    if (mounted) {
      setState(() {
        _isScanning = false;
        _currentPingTargetIP = null; // Clear when scan finishes
      });
    }
    debugPrint('Scan finished.');
  }
  
  void _stopScan() {
    setState(() {
      _isScanning = false;
      _currentPingTargetIP = null; // Clear if scan is stopped manually
    });
    debugPrint('Scan manually stopped by user.');
  }

  String _ipToComparable(String ip) {
    return ip.split('.').map((part) => part.padLeft(3, '0')).join('.');
  }

  @override
  void dispose() {
    _isScanning = false; 
    _currentPingTargetIP = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool useWideLayout = constraints.maxWidth >= kWideLayoutBreakpoint;

          Widget scanButton = Padding(
            padding: useWideLayout ? const EdgeInsets.only(bottom: kSpaceMedium) : kPagePadding,
            child: ElevatedButton(
              onPressed: () {
                if (_isScanning) {
                  _stopScan();
                } else {
                  _startScan();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isScanning 
                    ? Colors.redAccent 
                    : Theme.of(context).colorScheme.primary, // More defined for "Scan" state
                foregroundColor: _isScanning 
                    ? Colors.white // Ensure text is visible on redAccent
                    : Theme.of(context).colorScheme.onPrimary, // Standard text color for primary buttons
                minimumSize: const Size(220, 48), // Ensures consistent button size
              ),
              child: Text(_isScanning ? 'Stop Scan' : 'Scan Local Network'),
            ),
          );

          Widget localIpInfo = _localIP != null
              ? Padding(
                  padding: useWideLayout ? EdgeInsets.zero : kVerticalPaddingMedium,
                  child: Text('Your IP: $_localIP', style: Theme.of(context).textTheme.titleSmall),
                )
              : const SizedBox.shrink();

          Widget statsDisplaySection;
          if (_isScanning || _pingsSent > 0) {

            statsDisplaySection = Padding(
              padding: useWideLayout 
                  ? const EdgeInsets.symmetric(vertical: kSpaceSmall)
                  : const EdgeInsets.symmetric(vertical: kSpaceMedium, horizontal: kSpaceLarge),
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  if (_isScanning)
                    const CircularProgressIndicator( // Spinner is now fully opaque
                      strokeWidth: 3.0, 
                    ),
                  Card(
                    elevation: 2.0,
                    // Make card semi-transparent when scanning to show spinner behind it
                    color: _isScanning 
                        ? Theme.of(context).cardColor.withAlpha(50) // Approx 60% opaque. Adjust alpha (0-255) as needed.
                        : null, // Default card color when not scanning
                    child: Padding(
                      padding: const EdgeInsets.all(kSpaceSmall), // Inner padding for the card content
                      child: Column(
                        crossAxisAlignment: useWideLayout ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min, 
                        children: [
                          Text('Pings Sent: $_pingsSent'),
                          Text('Successful: $_successfulPings'),
                          Text('Failed/Timeout: $_unsuccessfulPings'),
                          if (_isScanning && _currentPingTargetIP != null)
                            Padding(padding: const EdgeInsets.only(top: kSpaceXSmall), child: Text('Pinging: $_currentPingTargetIP', style: Theme.of(context).textTheme.bodySmall)),
                        ],
                      ),
                    ),
                  ), 
                ],
              ),
            );
          } else {
            statsDisplaySection = const SizedBox.shrink();
          }

          Widget deviceList = Expanded(
            child: _discoveredDevices.isEmpty && !_isScanning && _pingsSent == 0
                ? const Center(child: Text('Tap scan to start.'))
                : _discoveredDevices.isEmpty && !_isScanning && _pingsSent > 0
                    ? const Center(child: Text('No devices found on the network.'))
                    : ListView.builder(
                    itemCount: _discoveredDevices.length,
                    itemBuilder: (context, index) {
                      final device = _discoveredDevices[index];
                      final subtitleParts = <String>[];
                      if (device.hostname != null && device.hostname != device.ip) subtitleParts.add('Hostname: ${device.hostname}');
                      if (device.pingTime != null) subtitleParts.add('Response Time: ${device.pingTime!.inMilliseconds}ms');

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: kSpaceMedium, vertical: kSpaceXSmall),
                        elevation: 2.0, 
                        child: ListTile(
                          title: Text(device.ip),
                          subtitle: subtitleParts.isNotEmpty ? Text(subtitleParts.join(' | ')) : null,
                        ),
                      );
                    },
                  ),
          );

          if (useWideLayout) {
            return Column(
              children: [
                Padding(
                  padding: kPagePadding,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [scanButton, localIpInfo],
                        ),
                      ),
                      kHorizontalSpacerMedium,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [statsDisplaySection],
                        ),
                      ),
                    ],
                  ),
                ),
                deviceList,
              ],
            );
          } else { // Narrow Layout
            return Column(
              children: <Widget>[
                scanButton, 
                localIpInfo, 
                statsDisplaySection, 
                deviceList
              ],
            );
          }
        },
      ),
    );
  }
}


class DiscoveredDevice {
  final String ip;
  String? hostname;
  Duration? pingTime;

  DiscoveredDevice({required this.ip, this.hostname, this.pingTime});

  @override
  String toString() =>
      'IP: $ip, Hostname: ${hostname ?? "N/A"}, Ping: ${pingTime?.inMilliseconds}ms';
}
