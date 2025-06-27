// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_yard/src/features/device/domain/device.dart';

/// A provider that holds the currently selected device for configuration.
final selectedDeviceProvider = StateProvider<Device?>((ref) => null);
