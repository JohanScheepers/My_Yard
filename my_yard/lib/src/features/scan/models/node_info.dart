class NodeInfo {
  final String id;
  final String ip;
  final String nodeType;
  final bool? led1Status;
  final bool? led2Status;
  final bool? airPumpStatus;
  final String? currentTime;

  NodeInfo({
    required this.id,
    required this.ip,
    required this.nodeType,
    this.led1Status,
    this.led2Status,
    this.airPumpStatus,
    this.currentTime,
  });

  factory NodeInfo.fromJson(Map<String, dynamic> json) {
    return NodeInfo(
      id: json['id'] as String,
      ip: json['ip'] as String,
      nodeType: json['nodeType'] as String,
      led1Status: json['led1Status'] as bool?,
      led2Status: json['led2Status'] as bool?,
      airPumpStatus: json['airPumpStatus'] as bool?,
      currentTime: json['currentTime'] as String?,
    );
  }

  // Method to convert NodeInfo to DeviceData (Map<String, String>)
  Map<String, String> toDeviceData() {
    final Map<String, String> data = {
      'id': id,
      'ip': ip,
      'type': nodeType, // Map nodeType to 'type' key for consistency with ConfigScreen
    };
    if (led1Status != null) data['led1Status'] = led1Status!.toString();
    if (led2Status != null) data['led2Status'] = led2Status!.toString();
    if (airPumpStatus != null) data['airPumpStatus'] = airPumpStatus!.toString();
    if (currentTime != null) data['currentTime'] = currentTime!;
    return data;
  }
}