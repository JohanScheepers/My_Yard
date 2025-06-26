// Copyright (c) [2025] Johan Scheepers
// GitHub: https://github.com/JohanScheepers/My_Yard

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_yard/src/constants/ui_constants.dart';
import 'package:my_yard/src/constants/text_styles.dart';
import 'package:my_yard/src/features/device/application/device_list_notifier.dart';
import 'package:my_yard/src/features/device/domain/device.dart';
import 'package:my_yard/src/features/scan/presentation/widgets/error_dialog.dart';

/// A dialog to display device information and offer to add it.
class AddDeviceDialog extends ConsumerWidget {
  const AddDeviceDialog({
    super.key,
    required this.device,
  });

  final Device device;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('Found Device'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text('ID: ${device.id}'),
            Text('IP: ${device.ip}'),
            Text('Type: ${device.nodeType}'),
            Text('Current Time: ${device.currentTime ?? 'N/A'}'),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Add Device'),
          onPressed: () async {
            Navigator.of(context).pop(); // Close the dialog first
            try {
              await ref
                  .read(deviceListNotifierProvider.notifier)
                  .addDevice(device);
              if (context.mounted) {
                final theme = Theme.of(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                        ),
                        const SizedBox(width: kSpaceMedium),
                        Expanded(
                          child: Text(
                            'Device ${device.id} added.',
                            style: kAppTextTheme.bodyMedium
                                ?.copyWith(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kBorderRadiusMedium),
                    ),
                    action: SnackBarAction(
                      label: 'UNDO',
                      textColor: theme.colorScheme.primary,
                      onPressed: () {
                        ref
                            .read(deviceListNotifierProvider.notifier)
                            .removeDevice(device.id);
                      },
                    ),
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                // Use the new ErrorDialog
                showDialog(
                  context: context,
                  builder: (dialogContext) => ErrorDialog(
                    message: e.toString().replaceFirst('Exception: ', ''),
                  ),
                );
              }
            }
          },
        ),
      ],
    );
  }
}
