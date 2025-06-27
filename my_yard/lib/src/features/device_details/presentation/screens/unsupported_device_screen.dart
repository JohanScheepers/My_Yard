// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard

import 'package:flutter/material.dart';

/// A widget to display when an unsupported device type is encountered.
class UnsupportedDeviceScreen extends StatelessWidget {
  const UnsupportedDeviceScreen({super.key, required this.nodeType});

  final String nodeType;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Unsupported device type: $nodeType'),
    );
  }
}
