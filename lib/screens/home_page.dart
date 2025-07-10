import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/screens/festival_page.dart';
import 'package:myapp/services/festival_service.dart';
import 'package:myapp/services/notification_service.dart';
import 'package:myapp/services/notification_storage_service.dart';
import 'package:myapp/utils/notification_helper.dart';
import 'package:myapp/widgets/festival_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FestivalService _festivalService = FestivalService();

  Stream<QuerySnapshot<Map<String, dynamic>>> _festivalsStream() {
    return _festivalService.getFestivalsStream();
  }

  @override
  void initState() {
    super.initState();

    // Chequeo de estado de notificaciones (Android 11+)
    Future.delayed(Duration.zero, () {
      NotificationHelper.checkNotificationStatus(context);
    });
  }

  Widget _buildFestivalCard(
    BuildContext context,
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return FestivalCard(
      name: (data['name'] ?? '').toString(),
      year: (data['year'] ?? '').toString(),
      dates: List<String>.from(data['date'] ?? []),
      city: (data['ciudad'] ?? '').toString(),
      country: (data['pais'] ?? '').toString(),
      stageNames: List<String>.from(data['stages'] ?? []),
      imageUrl: data['imageUrl'],
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => FestivalPage(
                  festivalId: doc.id,
                  festivalName: (data['name'] ?? '').toString(),
                  stageNames: List<String>.from(data['stages']),
                  dates: List<String>.from(data['date']),
                ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('onStagee'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implementar búsqueda
            },
          ),
          FutureBuilder<int>(
            future: NotificationStorageService().getUnreadCount(),
            builder: (context, snapshot) {
              final unreadCount = snapshot.data ?? 0;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      Navigator.pushNamed(context, '/notifications').then((
                        _,
                      ) async {
                        await NotificationStorageService().markAllAsRead();
                        setState(
                          () {},
                        ); // Actualiza contador de notificaciones no leídas
                      });
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _festivalsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar festivales'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text('No hay festivales disponibles.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder:
                (context, index) => _buildFestivalCard(context, docs[index]),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await NotificationService().showImmediateNotification();
        },
        child: const Icon(Icons.notifications),
      ),
    );
  }
}
