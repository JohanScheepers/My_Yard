// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_yard/src/features/device/domain/device.dart';

/// A repository for managing device data, persisting it to SharedPreferences.
class DeviceRepository {
  static const String _devicesKey = 'devices_list';

  /// Loads the list of devices from SharedPreferences.
  /// Returns an empty list if no devices are found or an error occurs.
  Future<List<Device>> loadDevices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? devicesJson = prefs.getString(_devicesKey);
      if (devicesJson != null) {
        final List<dynamic> decodedList = json.decode(devicesJson);
        return decodedList.map((json) => Device.fromJson(json)).toList();
      }
    } catch (e) {
      // In a real application, you would log this error more robustly.
      // For demonstration, we print it.
      print('Error loading devices: $e');
    }
    return [];
  }

  /// Saves the list of devices to SharedPreferences.
  Future<void> saveDevices(List<Device> devices) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> jsonList =
          devices.map((device) => device.toJson()).toList();
      final String encodedList = json.encode(jsonList);
      await prefs.setString(_devicesKey, encodedList);
    } catch (e) {
      print('Error saving devices: $e');
    }
  }
}

