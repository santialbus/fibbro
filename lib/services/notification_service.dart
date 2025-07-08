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

  Future<void> _init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: android);
    await _plugin.initialize(initSettings);
    tz.initializeTimeZones();
  }

  Future<void> scheduleIfNotExists(Artist artist) async {
    final prefs = await SharedPreferences.getInstance();
    final notifiedIds = prefs.getStringList('notified_artist_ids') ?? [];

    if (notifiedIds.contains(artist.id)) return;

    final artistDateTime = DateTime.parse('${artist.date} ${artist.time}');
    final notificationTime = artistDateTime.subtract(Duration(minutes: 10));

    if (notificationTime.isBefore(DateTime.now())) return;

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
    } catch (e) {
      print("Error al agendar notificación para ${artist.name}: $e");
    }

    notifiedIds.add(artist.id);
    await prefs.setStringList('notified_artist_ids', notifiedIds);
  }
}
