import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/artist.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  NotificationService() {
    _init();
  }

  Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: android);
    await _plugin.initialize(initSettings);
    tz.initializeTimeZones();

    if (Platform.isAndroid) {
      final androidImpl =
          _plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      if (androidImpl != null) {
        // Crear canal obligatorio en Android 8+
        await androidImpl.createNotificationChannel(
          const AndroidNotificationChannel(
            'onstagee_channel',
            'Recordatorios de artistas',
            description: 'Canal para notificaciones de artistas favoritos',
            importance: Importance.max,
          ),
        );

        final granted = await androidImpl.requestNotificationsPermission();
        print('🔔 Permiso de notificaciones concedido: $granted');
      }
    }
  }

  Future<void> _init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: android);
    await _plugin.initialize(initSettings);
    tz.initializeTimeZones();
  }

  Future<void> cancelNotification(String artistId) async {
    await _plugin.cancel(artistId.hashCode);

    final prefs = await SharedPreferences.getInstance();
    final notifiedIds = prefs.getStringList('notified_artist_ids') ?? [];

    notifiedIds.remove(artistId);
    await prefs.setStringList('notified_artist_ids', notifiedIds);

    print("🗑️ Notificación cancelada para $artistId");
  }

  Future<void> showImmediateNotification() async {
    await _plugin.show(
      9999,
      '🚨 Notificación de prueba',
      'Esto es una notificación lanzada inmediatamente',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'onstagee_channel',
          'Recordatorios de artistas',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<bool> scheduleIfNotExists(Artist artist) async {
    final prefs = await SharedPreferences.getInstance();
    final notifiedIds = prefs.getStringList('notified_artist_ids') ?? [];

    print(
      "⏰ ¿Ya estaba notificado? ${notifiedIds.contains(artist.id)} — Artista: ${artist.name}",
    );

    if (notifiedIds.contains(artist.id)) return false;

    final now = DateTime.now();
    final artistDateTime = DateTime.parse('${artist.date} ${artist.time}');
    final notificationTime = artistDateTime.subtract(
      const Duration(minutes: 10),
    );

    if (notificationTime.isBefore(now)) {
      print("⚠️ Notificación descartada (en el pasado): $notificationTime");
      return false;
    }

    try {
      await _plugin.zonedSchedule(
        artist.id.hashCode,
        'Actúa pronto: ${artist.name}',
        'Empieza a las ${artist.time} en el escenario ${artist.stage}',
        tz.TZDateTime.from(notificationTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'onstagee_channel',
            'Recordatorios de artistas',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );

      print(
        "✅ Notificación programada para ${artist.name} a las $notificationTime",
      );

      notifiedIds.add(artist.id);
      await prefs.setStringList('notified_artist_ids', notifiedIds);

      final pending = await _plugin.pendingNotificationRequests();
      print("🔔 Notificaciones pendientes: ${pending.length}");
      for (var n in pending) {
        print("🔔 ${n.id}: ${n.title} - ${n.body}");
      }
      return true;
    } catch (e) {
      print("❌ Error al agendar notificación para ${artist.name}: $e");
      return false;
    }
  }
}
