import 'package:flutter/material.dart';
import '../models/artist.dart';
import '../services/favorite_service.dart';
import '../services/notification_storage_service.dart';

class NotificationsPage extends StatefulWidget {
  final String userId;

  const NotificationsPage({super.key, required this.userId});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final FavoriteService _favoriteService = FavoriteService();
  final NotificationStorageService _notificationStorage =
      NotificationStorageService();

  List<Artist> favoriteArtists = [];
  List<Artist> unreadArtists = [];
  Map<String, List<String>> solapadosMap = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _markReadThenLoad();
  }

  Future<void> _markReadThenLoad() async {
    await _notificationStorage.markAllAsRead();
    await _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => isLoading = true);

    // 1. Cargar favoritos completos
    favoriteArtists = await _favoriteService.getFavoriteArtistsForUser(
      widget.userId,
    );

    // 2. Obtener IDs con notificación no leída
    final unreadIds = await _notificationStorage.getUnreadIds();

    // 3. Filtrar artistas no leídos (próximos)
    unreadArtists =
        favoriteArtists.where((a) => unreadIds.contains(a.id)).toList();

    // 4. Calcular solapados entre artistas favoritos
    solapadosMap = artistasSolapados(favoriteArtists);

    setState(() {
      isLoading = false;
    });
  }

  Map<String, List<String>> artistasSolapados(List<Artist> artistas) {
    Map<String, List<String>> solapamientos = {};

    int tiempoEnMinutos(String time) {
      final parts = time.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      if (hour < 6) hour += 24;
      return hour * 60 + minute;
    }

    List<Map<String, dynamic>> rangos =
        artistas.map((artist) {
          int inicio = artist.time != null ? tiempoEnMinutos(artist.time!) : 0;
          int duracion = artist.duration ?? 0;
          int fin = inicio + duracion;
          return {'id': artist.id, 'inicio': inicio, 'fin': fin};
        }).toList();

    for (int i = 0; i < rangos.length; i++) {
      for (int j = i + 1; j < rangos.length; j++) {
        final a = rangos[i];
        final b = rangos[j];

        bool seSolapan = (a['inicio'] < b['fin']) && (b['inicio'] < a['fin']);

        if (seSolapan) {
          solapamientos.putIfAbsent(a['id'], () => []);
          solapamientos.putIfAbsent(b['id'], () => []);
          solapamientos[a['id']]!.add(b['id']);
          solapamientos[b['id']]!.add(a['id']);
        }
      }
    }

    return solapamientos;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notificaciones')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones')),
      body: ListView(
        children: [
          if (unreadArtists.isNotEmpty) ...[
            const ListTile(title: Text('Próximos artistas con notificaciones')),
            ...unreadArtists.map(
              (artist) => ListTile(
                leading: const Icon(
                  Icons.notifications_active,
                  color: Colors.red,
                ),
                title: Text(artist.name),
                subtitle: Text(
                  'Empieza a las ${artist.time} en ${artist.stage}',
                ),
                trailing: Text(artist.date),
                onTap: () {
                  // Navegar a detalles o marcar individual como leído
                },
              ),
            ),
            const Divider(),
          ] else
            const ListTile(title: Text('No hay notificaciones pendientes.')),

          if (solapadosMap.isNotEmpty) ...[
            const ListTile(title: Text('Artistas con horarios solapados')),
            ...solapadosMap.entries.map((entry) {
              final artist = favoriteArtists.firstWhere(
                (a) => a.id == entry.key,
              );
              final overlappingArtists =
                  entry.value
                      .map(
                        (id) => favoriteArtists.firstWhere((a) => a.id == id),
                      )
                      .toList();

              return ExpansionTile(
                title: Text(
                  '${artist.name} y solapados (${overlappingArtists.length})',
                ),
                children:
                    overlappingArtists
                        .map(
                          (a) => ListTile(
                            title: Text(a.name),
                            subtitle: Text(
                              'Empieza a las ${a.time} en ${a.stage}',
                            ),
                            trailing: Text(a.date),
                          ),
                        )
                        .toList(),
              );
            }),
          ] else
            const ListTile(
              title: Text('No hay artistas con horarios solapados.'),
            ),
        ],
      ),
    );
  }
}
