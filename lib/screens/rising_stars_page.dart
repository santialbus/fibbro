import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/artist.dart';
import '../widgets/artist_card.dart';
import '../widgets/stage_app_bar.dart';
import '../services/favorite_service.dart';

class RisingStarsPage extends StatefulWidget {
  const RisingStarsPage({super.key});

  @override
  State<RisingStarsPage> createState() => _RisingStarsPageState();
}

class _RisingStarsPageState extends State<RisingStarsPage> {
  List<Artist> artists = [];
  Set<String> favoriteArtistIds = {}; // 🔥 Aquí se almacenan los favoritos
  bool isLoading = true;
  String? _errorMessage;

  int _currentDateIndex = 0;
  final List<String> _availableDates = [
    '2025-07-17',
    '2025-07-18',
    '2025-07-19',
  ];

  final FavoriteService favoriteService = FavoriteService();
  final String festivalId = '0e79d8ae-8c29-4f8e-a2bb-3a1eae9d2a77';

  @override
  void initState() {
    super.initState();
    loadArtists();
  }

  Future<void> loadArtists() async {
    setState(() {
      isLoading = true;
    });

    try {
      final jsonString = await rootBundle.loadString(
        'assets/docs/artists.json',
      );
      final List<dynamic> jsonData = json.decode(jsonString);
      final String currentDate = _availableDates[_currentDateIndex];

      final List<Artist> withTime =
          jsonData
              .map((json) => Artist.fromJson(json))
              .where(
                (artist) =>
                    artist.stage == 'Rising Stars' &&
                    artist.date == currentDate &&
                    artist.time != null,
              )
              .toList();

      withTime.sort((a, b) {
        int parseTime(String time) {
          final parts = time.split(':');
          int hour = int.parse(parts[0]);
          int minute = int.parse(parts[1]);
          if (hour < 6) hour += 24;
          return hour * 60 + minute;
        }

        return parseTime(a.time!) - parseTime(b.time!);
      });

      final List<Artist> withoutTime =
          jsonData
              .map((json) => Artist.fromJson(json))
              .where(
                (artist) =>
                    artist.stage == 'Rising Stars' &&
                    artist.date == currentDate &&
                    artist.time == null,
              )
              .toList();

      final List<Artist> all = [...withTime, ...withoutTime];

      // 🔥 Obtener favoritos del usuario para este festival
      final favs = await favoriteService.getFavoritesForFestival(festivalId);
      final favIds = favs.map((doc) => doc['artistId'] as String).toSet();

      setState(() {
        artists = all;
        favoriteArtistIds = favIds;
        isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        _errorMessage = 'Error cargando artistas';
      });
    }
  }

  void _changeDate(int newIndex) {
    setState(() {
      _currentDateIndex = newIndex;
    });
    loadArtists();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StageAppBar(
        stage: 'Rising Stars',
        dates: _availableDates,
        currentIndex: _currentDateIndex,
        onDateChanged: _changeDate,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : artists.isEmpty
              ? const Center(child: Text('No hay artistas para Rising Stars'))
              : ListView.builder(
                itemCount: artists.length,
                itemBuilder: (context, index) {
                  final artist = artists[index];
                  final isFav = favoriteArtistIds.contains(artist.id);

                  return ArtistCard(
                    artist: artist,
                    initiallyFavorite: isFav,
                    onFavoriteChanged: (isNowFav) async {
                      await favoriteService.toggleFavorite(
                        festivalId: festivalId,
                        artistId: artist.id,
                      );

                      setState(() {
                        if (isNowFav) {
                          favoriteArtistIds.add(artist.id);
                        } else {
                          favoriteArtistIds.remove(artist.id);
                        }
                      });
                    },
                  );
                },
              ),
    );
  }
}
