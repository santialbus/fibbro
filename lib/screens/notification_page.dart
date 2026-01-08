import 'package:flutter/material.dart';
import 'package:myapp/domain/artists_domain.dart';
import 'package:myapp/services/artist_service.dart';
import 'package:myapp/utils/app_logger.dart';
import 'package:myapp/utils/artist_overlap_utils.dart';
import '../services/notification_storage_service.dart';

class NotificationsPage extends StatefulWidget {
  final String userId;

  const NotificationsPage({super.key, required this.userId});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
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

  final unreadIds = await _notificationStorage.getUnreadIds();

  if (unreadIds.isEmpty) {
    unreadArtists = [];
    solapadosMap = {};
    setState(() => isLoading = false);
    return;
  }

  unreadArtists = await ArtistService.getArtistsByIds(
    artistIds: unreadIds,
  );

  solapadosMap = ArtistOverlapUtils.artistasSolapados(unreadArtists);

  setState(() {
    isLoading = false;
  });
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
              final artist = unreadArtists
                  .where((a) => a.id == entry.key)
                  .cast<FestivalArtistDomain?>()
                  .firstOrNull;

              final overlappingArtists =
              entry.value
                  .map(
                    (id) =>
                unreadArtists
                    .where((a) => a.id == id)
                    .cast<FestivalArtistDomain?>()
                    .firstOrNull,
              )
                  .whereType<FestivalArtistDomain>()
                  .toList();

              if (artist == null || overlappingArtists.isEmpty) {
                return const SizedBox.shrink();
              }

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
          ]

          else
            const ListTile(
              title: Text('No hay artistas con horarios solapados.'),
            ),
        ],
      ),
    );
  }
}
