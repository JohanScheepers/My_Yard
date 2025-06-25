// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard

import 'dart:convert';
import 'package:my_yard/src/features/device/domain/device.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'device_storage_service.g.dart';

class DeviceStorageService {
  DeviceStorageService(this._sharedPreferences);
  final SharedPreferences _sharedPreferences;

  static const _devicesKey = 'devices';

  Future<void> saveDevices(List<Device> devices) async {
    final deviceListJson = devices.map((d) => d.toJson()).toList();
    await _sharedPreferences.setString(_devicesKey, jsonEncode(deviceListJson));
  }

  List<Device> getDevices() {
    final jsonString = _sharedPreferences.getString(_devicesKey);
    if (jsonString == null) {
      return [];
    }
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => Device.fromJson(json)).toList();
  }
}

@Riverpod(keepAlive: true)
Future<DeviceStorageService> deviceStorageService(
    DeviceStorageServiceRef ref) async {
  final sharedPreferences = await SharedPreferences.getInstance();
  return DeviceStorageService(sharedPreferences);
}