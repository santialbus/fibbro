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

    // 1. Traer todos los favoritos completos (con festivalId y artistId)
    final allFavorites = await _favoriteService.getFavoritesForUserRaw(userId);

    // 2. Agrupar por festivalId -> lista de artistIds
    Map<String, List<String>> idsByFestival = {};
    for (final fav in allFavorites) {
      final festId = fav['festivalId'] as String;
      final artistId = fav['artistId'] as String;
      idsByFestival.putIfAbsent(festId, () => []).add(artistId);
    }

    Map<String, List<Artist>> loadedFavorites = {};
    Map<String, String> loadedFestivalNames = {};

    // 3. Por cada festival, cargar artistas y nombre
    for (final entry in idsByFestival.entries) {
      final festivalId = entry.key;
      final artistIds = entry.value;

      // Obtener nombre del festival (desde Firestore)
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
      body: ListView(
        children:
            favoritesByFestival.entries.map((entry) {
              final festivalId = entry.key;
              final artists = entry.value;
              final festivalName = festivalNames[festivalId] ?? 'Festival';

              return ExpansionTile(
                title: Text(festivalName),
                children:
                    artists
                        .map(
                          (artist) => ListTile(
                            title: Text(artist.name),
                            subtitle: Text(
                              '${artist.stage} - ${artist.date} ${artist.time}',
                            ),
                            onTap: () {
                              // Aquí puedes navegar a detalles del artista o festival, si quieres
                            },
                          ),
                        )
                        .toList(),
              );
            }).toList(),
      ),
    );
  }
}
