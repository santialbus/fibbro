import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:myapp/domain/artists_domain.dart';
import 'package:myapp/services/artist_service.dart';
import 'package:myapp/services/favorite_service.dart';
import 'package:myapp/utils/app_logger.dart';
import 'package:myapp/utils/artist_overlap_utils.dart';

class AllFavoritesPage extends StatefulWidget {
  const AllFavoritesPage({super.key});

  @override
  State<AllFavoritesPage> createState() => _AllFavoritesPageState();
}

class _AllFavoritesPageState extends State<AllFavoritesPage> {
  final FavoriteService _favoriteService = FavoriteService();
  bool isLoading = true;
  Map<String, List<FestivalArtistDomain>> favoritesByFestival = {};
  Map<String, String> festivalNames = {};

  @override
  void initState() {
    super.initState();
    AppLogger.page('AllFavoritesPage');
    initializeDateFormatting('es_ES', null).then((_) {
      loadFavoritesGrouped();
    });
  }

  Future<void> loadFavoritesGrouped() async {
    setState(() {
      isLoading = true;
    });

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final allFavorites = await _favoriteService.getFavoritesForUserRaw(userId);

    Map<String, List<String>> idsByFestival = {};
    for (final fav in allFavorites) {
      final festId = fav['festivalId'] as String;
      final artistId = fav['artistId'] as String;
      idsByFestival.putIfAbsent(festId, () => []).add(artistId);
    }

    Map<String, List<FestivalArtistDomain>> loadedFavorites = {};
    Map<String, String> loadedFestivalNames = {};

    for (final entry in idsByFestival.entries) {
      final festivalId = entry.key;
      final artistIds = entry.value;

      final festDoc =
          await FirebaseFirestore.instance
              .collection('festivales')
              .doc(festivalId)
              .get();

      loadedFestivalNames[festivalId] = festDoc.data()?['name'] ?? 'Festival';

      List<FestivalArtistDomain> artists;

      artists = [];
      const batchSize = 10;
      for (var i = 0; i < artistIds.length; i += batchSize) {
        final batchIds = artistIds.sublist(
          i,
          i + batchSize > artistIds.length ? artistIds.length : i + batchSize,
        );
        if (batchIds.isEmpty) continue;

        final allArtists = await ArtistService.getArtistsByIdsAndFestivalId(
          artistIds: batchIds,
          festivalId: festivalId,
        );

        artists.addAll(allArtists);
      }

      loadedFavorites[festivalId] = artists;
    }

    setState(() {
      favoritesByFestival = loadedFavorites;
      festivalNames = loadedFestivalNames;
      isLoading = false;
    });
  }

  DateTime parseFestivalDateTime(String? date, String? time) {
    final dateParts = date?.split('-').map(int.parse).toList();
    final timeParts = time?.split(':').map(int.parse).toList();

    final rawDateTime = DateTime(
      dateParts![0],
      dateParts[1],
      dateParts[2],
      timeParts![0],
      timeParts[1],
    );

    if (rawDateTime.hour < 6 || rawDateTime.hour < 16) {
      return rawDateTime.subtract(const Duration(days: 1));
    }

    return rawDateTime;
  }

  String formatFestivalDay(DateTime dateTime) {
    final formatter = DateFormat.EEEE('es_ES');
    final monthFormatter = DateFormat.MMMM('es_ES');
    return '${formatter.format(dateTime).capitalize()} ${dateTime.day} ${monthFormatter.format(dateTime)}';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mis favoritos')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (favoritesByFestival.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mis favoritos')),
        body: const Center(child: Text('No tienes favoritos añadidos')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mis favoritos')),
      body: RefreshIndicator(
        onRefresh: loadFavoritesGrouped,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          children:
              favoritesByFestival.entries.map((entry) {
                final festivalId = entry.key;
                final artists = entry.value;
                final festivalName = festivalNames[festivalId] ?? 'Festival';

                final Map<String, List<FestivalArtistDomain>> artistsByDay = {};

                for (final artist in artists) {
                  final dayKey = artist.festivalDate;
                  artistsByDay.putIfAbsent(dayKey, () => []).add(artist);
                }

                final sortedDays =
                    artistsByDay.keys.toList()..sort(
                      (a, b) => DateTime.parse(a).compareTo(DateTime.parse(b)),
                    );

                final dayWidgets = <Widget>[];

                for (final day in sortedDays) {
                  final date = DateTime.parse(day);
                  final artistsOfDay = artistsByDay[day]!;

                  artistsOfDay.sort((a, b) {
                    int parseTime(String time) {
                      final parts = time.split(':');
                      int hour = int.parse(parts[0]);
                      int minute = int.parse(parts[1]);
                      if (hour < 6) hour += 24;
                      return hour * 60 + minute;
                    }

                    return parseTime(a.startTime) - parseTime(b.startTime);
                  });

                  dayWidgets.add(
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        top: 12,
                        bottom: 4,
                      ),
                      child: Text(
                        formatFestivalDay(date),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  );

                  final solapadosMap = ArtistOverlapUtils.artistasSolapados(
                    artistsOfDay,
                  );

                  for (final artist in artistsOfDay) {
                    final overlappingIds = solapadosMap[artist.id] ?? [];
                    final overlappingArtists =
                        overlappingIds
                            .map(
                              (id) =>
                                  artistsOfDay.firstWhere((a) => a.id == id),
                            )
                            .toList();

                    dayWidgets.add(
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading:
                            artist.imageUrl != null &&
                                    artist.imageUrl!.isNotEmpty
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Image.network(
                                    artist.imageUrl!,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                  ),
                                )
                                : CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Colors.grey.shade300,
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  ),
                                ),
                        title: Text(
                          artist.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${artist.stage} • ${artist.festivalDate} ${artist.startTime}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (overlappingArtists.isNotEmpty)
                              Tooltip(
                                message:
                                    'Solapa con: ${overlappingArtists.map((a) => a.name).join(', ')}',
                                child: const Icon(
                                  Icons.error_outline,
                                  color: Colors.redAccent,
                                ),
                              ),
                            IconButton(
                              icon: const Icon(
                                Icons.favorite,
                                color: Colors.red,
                              ),
                              tooltip: 'Eliminar de favoritos',
                              onPressed: () async {
                                final userId =
                                    FirebaseAuth.instance.currentUser?.uid;
                                if (userId != null) {
                                  await _favoriteService.removeFavorite(
                                    artistId: artist.id,
                                    festivalId: festivalId,
                                  );
                                  await loadFavoritesGrouped();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${artist.name} eliminado de favoritos',
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),

                        onTap: () {},
                      ),
                    );
                  }
                }

                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    title: Text(
                      '$festivalName (${artists.length})',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    children: [
                      ...dayWidgets,
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8,
                        ),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: const Text('Eliminar todos'),
                                      content: const Text(
                                        '¿Seguro que quieres eliminar todos los favoritos de este festival?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, false),
                                          child: const Text('Cancelar'),
                                        ),
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, true),
                                          child: const Text('Eliminar'),
                                        ),
                                      ],
                                    ),
                              );

                              if (confirm == true) {
                                final userId =
                                    FirebaseAuth.instance.currentUser?.uid;
                                if (userId != null) {
                                  await _favoriteService
                                      .removeAllFavoritesForFestival(
                                        userId,
                                        festivalId,
                                      );
                                  await loadFavoritesGrouped();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Favoritos eliminados de $festivalName',
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.delete),
                            label: const Text('Eliminar todos'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}

extension StringCasingExtension on String {
  String capitalize() =>
      isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : '';
}
