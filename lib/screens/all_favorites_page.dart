import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/services/favorite_service.dart';

import '../models/artist.dart';

class AllFavoritesPage extends StatefulWidget {
  const AllFavoritesPage({super.key});

  @override
  State<AllFavoritesPage> createState() => _AllFavoritesPageState();
}

class _AllFavoritesPageState extends State<AllFavoritesPage> {
  final FavoriteService _favoriteService = FavoriteService();
  bool isLoading = true;
  Map<String, List<Artist>> favoritesByFestival = {}; // festivalId -> artistas
  Map<String, String> festivalNames = {}; // Para mostrar nombre festival

  @override
  void initState() {
    super.initState();
    loadFavoritesGrouped();
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

    Map<String, List<Artist>> loadedFavorites = {};
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

      // Cargar artistas favoritos de este festival (usando tu lógica adaptada)
      List<Artist> artists;
      if (festivalId == FavoriteService.fibFestivalId) {
        // Desde JSON local para FIB
        final jsonString = await rootBundle.loadString(
          'assets/docs/artists.json',
        );
        final jsonData = json.decode(jsonString) as List;
        final allArtists = jsonData.map((e) => Artist.fromJson(e)).toList();
        artists = allArtists.where((a) => artistIds.contains(a.id)).toList();
      } else {
        // Desde Firebase para otros festivales
        artists = [];
        const batchSize = 10;
        for (var i = 0; i < artistIds.length; i += batchSize) {
          final batchIds = artistIds.sublist(
            i,
            i + batchSize > artistIds.length ? artistIds.length : i + batchSize,
          );
          if (batchIds.isEmpty) continue;

          final artistsQuery =
              await FirebaseFirestore.instance
                  .collection('artists')
                  .where('id_festival', isEqualTo: festivalId)
                  .where(FieldPath.documentId, whereIn: batchIds)
                  .get();

          artists.addAll(
            artistsQuery.docs
                .map((doc) => Artist.fromJson({...doc.data(), 'id': doc.id}))
                .toList(),
          );
        }
      }

      loadedFavorites[festivalId] = artists;
    }

    setState(() {
      favoritesByFestival = loadedFavorites;
      festivalNames = loadedFestivalNames;
      isLoading = false;
    });
  }

  DateTime parseFestivalDateTime(String date, String time) {
    // Ejemplo: date = '2025-07-15', time = '01:30'
    final dateParts = date.split('-').map(int.parse).toList();
    final timeParts = time.split(':').map(int.parse).toList();

    final dateTime = DateTime(
      dateParts[0],
      dateParts[1],
      dateParts[2],
      timeParts[0],
      timeParts[1],
    );

    // Si es antes de las 6:00, pertenece al "día anterior" desde las 17:00
    if (dateTime.hour < 6) {
      return dateTime.subtract(const Duration(days: 1));
    }

    return dateTime;
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
                      ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: artists.length,
                        separatorBuilder:
                            (_, __) => const Divider(indent: 72, height: 1),
                        itemBuilder: (context, index) {
                          final artist = artists[index];
                          return ListTile(
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
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              '${artist.stage} • ${artist.date} ${artist.time}',
                            ),
                            trailing: IconButton(
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
                            onTap: () {
                              // Navegar a detalles si quieres
                            },
                          );
                        },
                      ),
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
