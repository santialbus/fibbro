import 'package:flutter/material.dart';
import 'package:myapp/services/notification_storage_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones')),
      body: const Center(child: Text('Aquí verás tus notificaciones')),
    );
  }

  @override
  void initState() {
    super.initState();
    NotificationStorageService().markAllAsRead();
  }
}
