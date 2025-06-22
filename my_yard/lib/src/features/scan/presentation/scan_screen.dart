// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard

import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'dart:async'; // For StreamSubscription
import 'dart:convert'; // For JSON encoding/decoding
import 'package:dart_ping/dart_ping.dart'; // Re-added for Ping functionality
import 'dart:io'; // For InternetAddress
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Added for Riverpod
import 'package:http/http.dart' as http; // For HTTP requests
import 'package:my_yard/src/constants/ui_constants.dart';
// Define a new class for the node information
import 'package:my_yard/src/features/scan/models/node_info.dart';
import 'package:my_yard/src/features/config/application/config_list_notifier.dart'; // Added for ConfigListNotifier

class ScanScreen extends ConsumerStatefulWidget { // Changed to ConsumerStatefulWidget
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  bool _isScanning = false; // Renamed from _isScanning to _isScanning
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
          SnackBar(
              content: Text(
                  'Failed to get local IP: $e. Ensure Wi-Fi is connected and permissions are granted.')),
        );
      }
    }
  }

  void _startScan() async {
    if (_localIP == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Could not determine local IP. Ensure Wi-Fi is connected.')),
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
      final ping = Ping(currentIP,
          count: 1, timeout: kPingTimeoutDuration); // Using constant
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
                _discoveredDevices.sort((a, b) =>
                    _ipToComparable(a.ip).compareTo(_ipToComparable(b.ip)));
                _successfulPings++;
                deviceFoundThisAttempt = true;
              }
            }
            debugPrint(
                'Found device: $currentIP ${hostname != null && hostname != currentIP ? "($hostname)" : ""} in ${pingTime?.inMilliseconds}ms');
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

  Future<void> _showNodeInfoDialog(DiscoveredDevice device) async {
    // Show a loading dialog immediately
    showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to close
      builder: (BuildContext dialogContext) {
        return const AlertDialog(
          title: Text('Node Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(height: kSpaceMedium),
              Text('Requesting node info...'),
            ],
          ),
        );
      },
    );

    NodeInfo? nodeInfo;
    String errorMessage = 'Unknown Node';

    try {
      // Construct the HTTP URL
      final String url = 'http://${device.ip}/';
      debugPrint('Sending HTTP GET request to $url');

      // Make the HTTP GET request with a timeout
      final response = await http.get(Uri.parse(url)).timeout(
            kHttpRequestTimeoutDuration, // Use a new constant for HTTP timeout
            onTimeout: () {
              throw TimeoutException('HTTP request to ${device.ip} timed out.');
            },
      );

      if (response.statusCode == 200) {
        final String responseBody = response.body;
        debugPrint('Received HTTP response from ${device.ip}: $responseBody');
        final Map<String, dynamic> jsonResponse =
            jsonDecode(responseBody) as Map<String, dynamic>;
        nodeInfo = NodeInfo.fromJson(jsonResponse);
        
        // Store the discovered node information in ConfigListNotifier
        ref.read(configListNotifierProvider.notifier).addDevice(
          nodeInfo.toDeviceData(), // Convert NodeInfo to DeviceData
        );
              
      } else {
        errorMessage =
            'HTTP Error: ${response.statusCode} - ${response.reasonPhrase}';
        debugPrint(
            'HTTP request failed for ${device.ip}: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      errorMessage = 'Network error: ${e.message}';
      debugPrint('UDP SocketException: $e');
    } on FormatException catch (e) {
      errorMessage = 'Invalid JSON response: ${e.message}';
      debugPrint('UDP FormatException: $e');
    } catch (e) {
      errorMessage = 'An unexpected error occurred: $e'; // Catch TimeoutException here too
      debugPrint('HTTP General Error: $e');
    } finally {
    }

    // Dismiss the loading dialog
    if (mounted) {
      Navigator.of(context).pop();
    }

    // Show the result dialog
    if (mounted) {
      showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Node Information'),
            content: nodeInfo != null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('ID: ${nodeInfo.id}'),
                      Text('IP: ${nodeInfo.ip}'),
                      Text('Type: ${nodeInfo.nodeType}'),
                      // Add other fields from NodeInfo if available and relevant
                      if (nodeInfo.led1Status != null)
                        Text('LED 1: ${nodeInfo.led1Status! ? 'ON' : 'OFF'}'),
                      if (nodeInfo.led2Status != null)
                        Text('LED 2: ${nodeInfo.led2Status! ? 'ON' : 'OFF'}'),
                      if (nodeInfo.airPumpStatus != null)
                        Text('Air Pump: ${nodeInfo.airPumpStatus! ? 'ON' : 'OFF'}'),
                      if (nodeInfo.currentTime != null)
                        Text('Time: ${nodeInfo.currentTime}'),
                    ],
                  )
                : Text(errorMessage),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    }
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
          final bool useWideLayout =
              constraints.maxWidth >= kWideLayoutBreakpoint;

          Widget scanButton = Padding(
            padding: useWideLayout
                ? const EdgeInsets.only(bottom: kSpaceMedium)
                : kPagePadding,
            child: ElevatedButton(
              onPressed: () {
                if (_isScanning) {
                  _stopScan();
                } else {
                  _startScan();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isScanning // Using theme colors
                    ? Colors.redAccent
                    : Theme.of(context)
                        .colorScheme
                        .primary, // More defined for "Scan" state
                foregroundColor: _isScanning
                    ? Colors.white // Ensure text is visible on redAccent
                    : Theme.of(context)
                        .colorScheme
                        .onPrimary, // Standard text color for primary buttons
                minimumSize: kButtonMinSize, // Using constant
              ),
              child: Text(_isScanning ? 'Stop Scan' : 'Scan Local Network'),
            ),
          );

          Widget localIpInfo = _localIP != null
              ? Padding(
                  // Using constant
                  padding:
                      useWideLayout ? EdgeInsets.zero : kVerticalPaddingMedium,
                  child: Text('Your IP: $_localIP',
                      style: Theme.of(context).textTheme.titleSmall),
                )
              : kVerticalSpacerMedium; // Using a spacer for consistency when IP is null

          Widget statsDisplaySection;
          if (_isScanning || _pingsSent > 0) {
            statsDisplaySection = Padding(
              padding: useWideLayout
                  ? const EdgeInsets.symmetric(vertical: kSpaceSmall)
                  : const EdgeInsets.symmetric(
                      vertical: kSpaceMedium, horizontal: kSpaceLarge),
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  if (_isScanning) // Using constant
                    const CircularProgressIndicator(
                      strokeWidth: kCircularProgressStrokeWidth,
                    ),
                  Card(
                    elevation: kCardElevationDefault, // Using constant
                    // Make card semi-transparent when scanning to show spinner behind it
                    color: _isScanning
                        ? Theme.of(context)
                            .cardColor
                            .withAlpha(kCardOverlayAlpha) // Using constant
                        : null, // Default card color when not scanning
                    child: Padding(
                      padding: const EdgeInsets.all(
                          kSpaceSmall), // Inner padding for the card content
                      child: Column(
                        crossAxisAlignment: useWideLayout
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Pings Sent: $_pingsSent'),
                          Text('Successful: $_successfulPings'),
                          Text('Failed/Timeout: $_unsuccessfulPings'),
                          if (_isScanning && _currentPingTargetIP != null)
                            Padding(
                                // Using constant
                                padding:
                                    const EdgeInsets.only(top: kSpaceXSmall),
                                child: Text('Pinging: $_currentPingTargetIP',
                                    style:
                                        Theme.of(context).textTheme.bodySmall)),
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
                    ? const Center(
                        child: Text('No devices found on the network.'))
                    : ListView.builder(
                        itemCount: _discoveredDevices.length,
                        itemBuilder: (context, index) {
                          final device = _discoveredDevices[index];
                          final subtitleParts = <String>[];
                          if (device.hostname != null &&
                              device.hostname != device.ip) {
                            subtitleParts.add('Hostname: ${device.hostname}');
                          }
                          if (device.pingTime != null) {
                            subtitleParts.add(
                                'Response Time: ${device.pingTime!.inMilliseconds}ms');
                          }

                          return Card(
                            // Using constants
                            // Add onTap to show the node info dialog
                            elevation: kCardElevationDefault,
                            margin: const EdgeInsets.symmetric(
                                horizontal: kSpaceMedium,
                                vertical: kSpaceXSmall),
                            child: ListTile(
                              title: Text(device.ip),
                              subtitle: subtitleParts.isNotEmpty
                                  ? Text(subtitleParts.join(' | '))
                                  : null,
                              onTap: () => _showNodeInfoDialog(device),
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
          } else {
            // Narrow Layout
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
