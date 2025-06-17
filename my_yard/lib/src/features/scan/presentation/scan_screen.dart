import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'dart:async'; // For StreamSubscription
import 'package:dart_ping/dart_ping.dart';
import 'dart:io'; // For InternetAddress

class DiscoveredDevice {
  final String ip;
  String? hostname;
  Duration? pingTime;

  DiscoveredDevice({required this.ip, this.hostname, this.pingTime});

  @override
  String toString() => 'IP: $ip, Hostname: ${hostname ?? "N/A"}, Ping: ${pingTime?.inMilliseconds}ms';
}

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _isScanning = false;
  List<DiscoveredDevice> _discoveredDevices = [];
  // StreamSubscription is no longer needed with dart_ping in this manner
  String? _localIP;

  @override
  void initState() {
    super.initState();
    _getLocalIP();
  }

  Future<void> _getLocalIP() async {
    final networkInfo = NetworkInfo();
    try {
      _localIP = await networkInfo.getWifiIP();
      setState(() {});
    } catch (e) {
      debugPrint("Failed to get local IP: $e");
      // Handle error, maybe show a message to the user
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
    });

    final String subnet = _localIP!.substring(0, _localIP!.lastIndexOf('.'));

    // Iterate over a range of IPs in the subnet (e.g., 1 to 254)
    // This can be slow. Consider a smaller range or a more targeted approach if possible.
    for (int i = 1; i < 255; i++) {
      if (!_isScanning) break; // Stop if scanning is cancelled

      final String currentIP = '$subnet.$i';
      // Skip pinging the device's own IP if you want
      // if (currentIP == _localIP) continue;

      final ping = Ping(currentIP, count: 1, timeout: 1); // 1 ping, 1 second timeout

      // It's better to handle the stream for each ping individually
      // or manage a pool of pings if doing many concurrently.
      // For simplicity, we'll await each one, which will be slow.
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
              // Hostname remains null
            }
            if (mounted) {
              setState(() {
                // Avoid adding duplicates if somehow a device responds multiple times quickly
                // though 'break' below should prevent this for a single IP.
                if (!_discoveredDevices.any((d) => d.ip == currentIP)) {
                  _discoveredDevices.add(DiscoveredDevice(
                    ip: currentIP,
                    hostname: hostname,
                    pingTime: pingTime,
                  ));
                  _discoveredDevices.sort((a, b) => _ipToComparable(a.ip).compareTo(_ipToComparable(b.ip)));
                }
              });
            }
            debugPrint('Found device: $currentIP ${hostname != null && hostname != currentIP ? "($hostname)" : ""} in ${pingTime?.inMilliseconds}ms');
            break; // Found, no need to wait for more from this IP's stream
          }
        }
      } catch (e) {
        // This catch block might be for errors during ping setup, not necessarily for timeouts
        debugPrint('Error pinging $currentIP: $e');
      }
    }

    if (mounted) {
      setState(() {
        _isScanning = false;
      });
    }
    debugPrint('Scan finished.');
  }

  // Helper to sort IPs numerically
  String _ipToComparable(String ip) {
    return ip.split('.').map((part) => part.padLeft(3, '0')).join('.');
  }



  @override
  void dispose() {
    _isScanning = false; // Ensure any ongoing loops in _startScan stop
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _isScanning ? null : _startScan,
              child: Text(_isScanning ? 'Scanning...' : 'Scan Local Network'),
            ),
          ),
          if (_localIP != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text('Your IP: $_localIP', style: Theme.of(context).textTheme.titleSmall),
            ),
          if (_isScanning)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          Expanded(
            child: _discoveredDevices.isEmpty && !_isScanning
                ? const Center(child: Text('No devices found yet. Tap scan to start.'))
                : ListView.builder(
                    itemCount: _discoveredDevices.length,
                    itemBuilder: (context, index) {
                      final device = _discoveredDevices[index];
                      final subtitleParts = <String>[];
                      if (device.hostname != null && device.hostname != device.ip) subtitleParts.add('Hostname: ${device.hostname}');
                      if (device.pingTime != null) subtitleParts.add('Ping: ${device.pingTime!.inMilliseconds}ms');
                      return ListTile(
                        title: Text(device.ip),
                        subtitle: subtitleParts.isNotEmpty ? Text(subtitleParts.join(' | ')) : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
