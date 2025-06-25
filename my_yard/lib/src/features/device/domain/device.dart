// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard

import 'package:json_annotation/json_annotation.dart';

part 'device.g.dart';

/// A model representing a single IoT device in the yard.
@JsonSerializable()
class Device {
  const Device({
    required this.id,
    required this.ip,
    required this.nodeType,
    this.currentTime,
  });

  final String id;
  final String ip;
  final String nodeType;
  final String? currentTime;

  /// Creates a [Device] from a JSON map.
  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);

  /// Converts this [Device] instance to a JSON map.
  Map<String, dynamic> toJson() => _$DeviceToJson(this);

  /// Creates a copy of this [Device] but with the given fields replaced with
  /// the new values.
  Device copyWith(
      {String? id, String? ip, String? nodeType, String? currentTime}) {
    return Device(
        id: id ?? this.id,
        ip: ip ?? this.ip,
        nodeType: nodeType ?? this.nodeType,
        currentTime: currentTime ?? this.currentTime);
  }
}