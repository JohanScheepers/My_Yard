// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Device _$DeviceFromJson(Map<String, dynamic> json) => Device(
      id: json['id'] as String,
      ip: json['ip'] as String,
      nodeType: json['nodeType'] as String,
      currentTime: json['currentTime'] as String?,
    );

Map<String, dynamic> _$DeviceToJson(Device instance) => <String, dynamic>{
      'id': instance.id,
      'ip': instance.ip,
      'nodeType': instance.nodeType,
      'currentTime': instance.currentTime,
    };
