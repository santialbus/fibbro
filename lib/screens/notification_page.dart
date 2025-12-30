import 'package:flutter/material.dart';
import 'package:myapp/domain/artists_domain.dart';
import 'package:myapp/utils/app_logger.dart';
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

  List<FestivalArtistDomain> favoriteArtists = [];
  List<FestivalArtistDomain> unreadArtists = [];
  Map<String, List<String>> solapadosMap = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    AppLogger.page('NotificationPage');
    _markReadThenLoad();
  }

  Future<void> _markReadThenLoad() async {
    // Aquí no borramos todo para que las notificaciones no desaparezcan solas
    // Si quieres borrar todo al abrir, descomenta esta línea:
    // await _notificationStorage.markAllAsRead();

    await _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => isLoading = true);

    favoriteArtists = await _favoriteService.getFavoriteArtistsForUser(
      widget.userId,
    );
    final unreadIds = await _notificationStorage.getUnreadIds();
    unreadArtists =
        favoriteArtists.where((a) => unreadIds.contains(a.id)).toList();

    solapadosMap = artistasSolapados(favoriteArtists);

    setState(() {
      isLoading = false;
    });
  }

  Map<String, List<String>> artistasSolapados(List<FestivalArtistDomain> artistas) {
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
          // ignore: unnecessary_null_comparison
          int inicio = artist.startTime != null ? tiempoEnMinutos(artist.startTime) : 0;
          int duracion = artist.duration;
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

  // Método para borrar una notificación individual
  Future<void> _deleteNotification(String artistId) async {
    await _notificationStorage.markAsRead(artistId);
    await _loadNotifications();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Notificación eliminada')));
  }

  // Método para borrar todas las notificaciones
  Future<void> _deleteAllNotifications() async {
    await _notificationStorage.markAllAsRead();
    await _loadNotifications();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Todas las notificaciones eliminadas')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Notificaciones'),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: null, // Deshabilitado mientras carga
            ),
          ],
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Eliminar todas las notificaciones',
            onPressed:
                unreadArtists.isEmpty
                    ? null
                    : () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Confirmar'),
                              content: const Text(
                                '¿Quieres eliminar todas las notificaciones?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(true),
                                  child: const Text('Eliminar'),
                                ),
                              ],
                            ),
                      );
                      if (confirm == true) {
                        await _deleteAllNotifications();
                      }
                    },
          ),
        ],
      ),
      body: ListView(
        children: [
          if (unreadArtists.isNotEmpty) ...[
            const ListTile(title: Text('Próximos artistas con notificaciones')),
            ...unreadArtists.map(
              (artist) => Dismissible(
                key: Key(artist.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  _deleteNotification(artist.id);
                },
                child: ListTile(
                  leading: const Icon(
                    Icons.notifications_active,
                    color: Colors.red,
                  ),
                  title: Text(artist.name),
                  subtitle: Text(
                    'Empieza a las ${artist.startTime} en ${artist.stage}',
                  ),
                  trailing: Text(artist.festivalDate),
                  onTap: () {
                    // Puedes navegar a detalles o marcar individual como leído aquí si quieres
                  },
                ),
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
                              'Empieza a las ${a.startTime} en ${a.stage}',
                            ),
                            trailing: Text(a.festivalDate),
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
