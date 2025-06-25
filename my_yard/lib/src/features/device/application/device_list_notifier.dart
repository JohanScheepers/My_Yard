// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:my_yard/src/features/device/application/device_storage_service.dart';
import 'package:my_yard/src/features/device/domain/device.dart';

part 'device_list_notifier.g.dart';

@Riverpod(keepAlive: true)
class DeviceListNotifier extends _$DeviceListNotifier {
  @override
  Future<List<Device>> build() async {
    final storageService = await ref.watch(deviceStorageServiceProvider.future);
    return storageService.getDevices();
  }

  Future<void> addDevice(Device device) async {
    final storageService = await ref.read(deviceStorageServiceProvider.future);
    final previousState = await future;

    // Check for duplicates by ID or IP address
    final isDuplicate =
        previousState.any((d) => d.id == device.id || d.ip == device.ip);
    if (isDuplicate) {
      throw Exception('Device with the same ID or IP already exists.');
    }

    final newState = [...previousState, device];
    state = AsyncData(newState);
    await storageService.saveDevices(newState);
  }

  Future<void> removeDevice(String deviceId) async {
    final storageService = await ref.read(deviceStorageServiceProvider.future);
    final previousState = await future;
    final newState = previousState.where((d) => d.id != deviceId).toList();
    state = AsyncData(newState);
    await storageService.saveDevices(newState);
  }
}