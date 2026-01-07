import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationPermissionService {
  Future<bool> areNotificationsGranted() async {
    if (!Platform.isAndroid) return true;
    return Permission.notification.isGranted;
  }

  Future<void> requestIfNeeded(BuildContext context) async {
    final granted = await areNotificationsGranted();

    if (!granted && context.mounted) {
      await _showPermissionDialog(context);
    }
  }

  Future<void> _showPermissionDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notificaciones desactivadas'),
        content: const Text(
          'Las notificaciones están desactivadas para esta app. '
          'Actívalas manualmente para recibir avisos de tus artistas favoritos.',
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await openAppSettings();
            },
            child: const Text('Abrir ajustes'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }
}
