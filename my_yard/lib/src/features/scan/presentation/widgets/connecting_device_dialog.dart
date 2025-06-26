// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard

import 'package:flutter/material.dart';
import 'package:my_yard/src/constants/ui_constants.dart';

/// A dialog shown while connecting to a device.
class ConnectingDeviceDialog extends StatelessWidget {
  const ConnectingDeviceDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return const AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: kSpaceMedium),
          Text('Connecting to device...'),
        ],
      ),
    );
  }
}
