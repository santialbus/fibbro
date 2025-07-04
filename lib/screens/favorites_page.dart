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

  final List<String> _availableDates = [
    '2025-07-17',
    '2025-07-18',
    '2025-07-19',
  ];
  int _currentDateIndex = 0;

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    loadFavorites();
  }

  // Formateo manual de fecha sin intl
  String formatFullDate(String isoDate) {
    final date = DateTime.parse(isoDate);

    const days = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];

    final dayName = days[date.weekday - 1];
    final day = date.day;
    final monthName = months[date.month - 1];

    return '$dayName, $day de $monthName';
  }

  Future<void> loadFavorites() async {
    if (_userId.isEmpty) {
      setState(() {
        favoriteArtists = [];
        isLoading = false;
      });
      return;
    }

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

      // Ordenar por fecha y hora (hora nocturna de 17:00 a 6:00)
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
        favoriteArtists = [];
      });
    }
  }

  void _changeDate(int newIndex) {
    setState(() {
      _currentDateIndex = newIndex;
    });
    loadFavorites(); // Recarga al cambiar fecha para mantener sincronía
  }

  @override
  Widget build(BuildContext context) {
    final currentDate = _availableDates[_currentDateIndex];
    final artistsOfDay =
        favoriteArtists.where((artist) => artist.date == currentDate).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Mis favoritos'), centerTitle: true),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : favoriteArtists.isEmpty
              ? const Center(child: Text('Aún no has añadido favoritos'))
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed:
                              _currentDateIndex > 0
                                  ? () => _changeDate(_currentDateIndex - 1)
                                  : null,
                        ),
                        Text(
                          formatFullDate(currentDate),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed:
                              _currentDateIndex < _availableDates.length - 1
                                  ? () => _changeDate(_currentDateIndex + 1)
                                  : null,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: artistsOfDay.length,
                      itemBuilder: (context, index) {
                        final artist = artistsOfDay[index];
                        return ArtistCard(
                          artist: artist,
                          initiallyFavorite: true,
                          onFavoriteChanged: (isFav) async {
                            await _favoriteService.toggleFavorite(
                              artistId: artist.id,
                              festivalId: _festivalId,
                            );
                            loadFavorites();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
    );
  }
}
