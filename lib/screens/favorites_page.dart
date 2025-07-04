import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/artist.dart';
import '../widgets/artist_card.dart';
import '../services/favorite_service.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final FavoriteService _favoriteService = FavoriteService();
  final String _festivalId = '0e79d8ae-8c29-4f8e-a2bb-3a1eae9d2a77';
  late final String _userId;

  List<Artist> favoriteArtists = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    setState(() => isLoading = true);

    try {
      final favoriteIds = await _favoriteService.getFavoriteArtistIdsForUser(
        userId: _userId,
        festivalId: _festivalId,
      );

      final jsonString = await rootBundle.loadString(
        'assets/docs/artists.json',
      );
      final List<dynamic> jsonData = json.decode(jsonString);

      final allArtists = jsonData.map((e) => Artist.fromJson(e)).toList();

      final filtered =
          allArtists
              .where((artist) => favoriteIds.contains(artist.id))
              .toList();

      // Ordenación por fecha y hora (nocturna)
      filtered.sort((a, b) {
        final dateCompare = a.date.compareTo(b.date);
        if (dateCompare != 0) return dateCompare;

        int parseTime(String? time) {
          if (time == null) return 9999;
          final parts = time.split(':');
          int hour = int.parse(parts[0]);
          int minute = int.parse(parts[1]);
          if (hour < 6) hour += 24;
          return hour * 60 + minute;
        }

        return parseTime(a.time) - parseTime(b.time);
      });

      setState(() {
        favoriteArtists = filtered;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis favoritos'), centerTitle: true),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : favoriteArtists.isEmpty
              ? const Center(child: Text('Aún no has añadido favoritos'))
              : ListView.builder(
                itemCount: favoriteArtists.length,
                itemBuilder: (context, index) {
                  final artist = favoriteArtists[index];
                  return ArtistCard(
                    artist: artist,
                    initiallyFavorite: true,
                    onFavoriteChanged: (isFav) async {
                      await _favoriteService.toggleFavorite(
                        artistId: artist.id,
                        festivalId: _festivalId,
                      );
                      loadFavorites(); // refrescar tras cambio
                    },
                  );
                },
              ),
    );
  }
}
