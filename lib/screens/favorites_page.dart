import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/artist.dart';
import '../widgets/artist_favorite_card.dart';
import '../services/favorite_service.dart';

class FavoritesPage extends StatefulWidget {
  final String festivalId;
  final List<String> dates;

  const FavoritesPage({
    super.key,
    required this.festivalId,
    required this.dates,
  });

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final FavoriteService _favoriteService = FavoriteService();
  late final String _festivalId;
  late final String _userId;
  late final List<String> _dates;

  List<Artist> favoriteArtists = [];
  bool isLoading = true;

  final List<String> _availableDates = [
    '2025-07-17',
    '2025-07-18',
    '2025-07-19',
  ];
  int _currentDateIndex = 0;

  bool get isFib => _festivalId == '0e79d8ae-8c29-4f8e-a2bb-3a1eae9d2a77';

  @override
  void initState() {
    super.initState();
    _festivalId = widget.festivalId;
    _userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    _dates = widget.dates;
    loadFavorites();
  }

  // Normaliza la fecha a yyyy-MM-dd
  String normalizeDate(String date) {
    // Si formato dd/MM/yyyy o dd-MM-yyyy, lo invierte a yyyy-MM-dd
    if (RegExp(r'^\d{2}[-/]\d{2}[-/]\d{4}$').hasMatch(date)) {
      final parts = date.split(RegExp(r'[-/]'));
      return '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
    }
    // Reemplaza / por - si ya es yyyy/MM/dd o yyyy-MM-dd
    return date.replaceAll('/', '-');
  }

  List<String> getDates() {
    List<String> dates = isFib ? _availableDates : _dates;
    return dates.map(normalizeDate).toList();
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

  String formatFullDate(String rawDate) {
    final isoDate = normalizeDate(rawDate);
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

      List<Artist> allArtists = [];

      if (isFib) {
        final jsonString = await rootBundle.loadString(
          'assets/docs/artists.json',
        );
        final jsonData = json.decode(jsonString);
        allArtists = (jsonData as List).map((e) => Artist.fromJson(e)).toList();
      } else {
        final batchedIds = favoriteIds.take(10).toList();

        final querySnapshot =
            await FirebaseFirestore.instance
                .collection('artists')
                .where(FieldPath.documentId, whereIn: batchedIds)
                .get();

        allArtists =
            querySnapshot.docs
                .map((doc) => Artist.fromJson({...doc.data(), 'id': doc.id}))
                .toList();
      }

      final filtered =
          allArtists
              .where((artist) => favoriteIds.contains(artist.id))
              .toList();

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
    loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final currentDate = getDates()[_currentDateIndex];
    final artistsOfDay =
        favoriteArtists.where((a) => a.date == currentDate).toList();
    final solapadosMap = artistasSolapados(artistsOfDay);

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
                              _currentDateIndex < getDates().length - 1
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
                        final overlappingIds = solapadosMap[artist.id] ?? [];
                        final overlappingArtists =
                            overlappingIds
                                .map(
                                  (id) => artistsOfDay.firstWhere(
                                    (a) => a.id == id,
                                  ),
                                )
                                .toList();

                        return ArtistFavoriteCard(
                          artist: artist,
                          initiallyFavorite: true,
                          showAlert: overlappingArtists.isNotEmpty,
                          overlappingArtists: overlappingArtists,
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
