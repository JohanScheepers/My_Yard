// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'config_list_notifier.g.dart';

const String _kConfiguredDevicesKey = 'configured_devices_list';

/// A typedef for device data. In a real app, this would be a dedicated model class.
/// Example: {'ip': '192.168.1.10', 'name': 'My ESP32', 'type': 'esp32'}
typedef DeviceData = Map<String, String>;

@Riverpod(keepAlive: true)
class ConfigListNotifier extends _$ConfigListNotifier {
  SharedPreferences? _prefs;

  @override
  Future<List<DeviceData>> build() async {
    _prefs = await SharedPreferences.getInstance();
    return _loadDevicesFromPrefs();
  }

  List<DeviceData> _loadDevicesFromPrefs() {
    final List<String>? devicesJson =
        _prefs?.getStringList(_kConfiguredDevicesKey);
    if (devicesJson != null) {
      try {
        return devicesJson
            .map((jsonString) => DeviceData.from(jsonDecode(jsonString) as Map))
            .toList();
      } catch (e) {
        debugPrint(
            'Error decoding configured devices from SharedPreferences: $e');
        // Optionally clear corrupted data
        // _prefs?.remove(_kConfiguredDevicesKey);
        return [];
      }
    }
    return [];
  }

  Future<void> _saveDevicesToPrefs(List<DeviceData> devices) async {
    final List<String> devicesJson =
        devices.map((device) => jsonEncode(device)).toList();
    await _prefs?.setStringList(_kConfiguredDevicesKey, devicesJson);
  }

  Future<void> addDevice(DeviceData newDevice) async {
    final currentDevices = List<DeviceData>.from(state.value ?? []);
    // Avoid adding duplicates based on IP (assuming IP is a unique identifier)
    if (!currentDevices.any((d) => d['ip'] == newDevice['ip'])) {
      currentDevices.add(newDevice);
      state = AsyncData(List.from(
          currentDevices)); // Ensure new list instance for state change
      await _saveDevicesToPrefs(currentDevices);
    }
  }

  Future<void> removeDevice(DeviceData deviceToRemove) async {
    final currentDevices = List<DeviceData>.from(state.value ?? []);
    currentDevices.removeWhere((d) => d['ip'] == deviceToRemove['ip']);
    state = AsyncData(List.from(currentDevices)); // Ensure new list instance
    await _saveDevicesToPrefs(currentDevices);
  }

  Future<void> clearAllDevices() async {
    state = const AsyncData([]);
    await _prefs?.remove(_kConfiguredDevicesKey);
  }

  // Method to manually refresh or reload from prefs if needed
  Future<void> refreshDevices() async {
    state = const AsyncLoading(); // Show loading state
    state = await AsyncValue.guard(() async => _loadDevicesFromPrefs());
  }
}
