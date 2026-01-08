import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationHelper {
  static Future<void> checkNotificationStatus(BuildContext context) async {
    if (!Platform.isAndroid) return;

    final isGranted = await Permission.notification.isGranted;

    if (!isGranted) {
      showDialog(
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
                await openAppSettings(); // Abre ajustes del sistema
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
}