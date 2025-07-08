import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/artist.dart';
import '../widgets/artist_card.dart';
import '../widgets/stage_app_bar.dart';
import '../services/favorite_service.dart';

class StagePage extends StatefulWidget {
  final String festivalId;
  final String stageName;
  final List<String> dates;

  const StagePage({
    super.key,
    required this.festivalId,
    required this.stageName,
    required this.dates,
  });

  @override
  State<StagePage> createState() => _StagePageState();
}

class _StagePageState extends State<StagePage> {
  List<Artist> artists = [];
  Set<String> favoriteArtistIds = {};
  bool isLoading = true;
  int currentDateIndex = 0;

  final FavoriteService favoriteService = FavoriteService();

  @override
  void initState() {
    super.initState();
    loadArtists();
  }

  String convertDateFormat(String date) {
  final parts = date.split('/');
  if (parts.length == 3) {
    final day = parts[0].padLeft(2, '0');
    final month = parts[1].padLeft(2, '0');
    final year = parts[2];
    return '$year-$month-$day';
  }
  return date; // fallback si ya está bien
}

  Future<void> loadArtists() async {
    setState(() => isLoading = true);

    try {
      final String currentDateRaw = widget.dates[currentDateIndex];
      final String currentDate = convertDateFormat(currentDateRaw);      print('Cargando artistas para:');
      print('Festival: ${widget.festivalId}');
      print('Stage: ${widget.stageName}');
      print('Date: $currentDate');

      // 🔥 Nueva consulta directa por campos
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('artists')
              .where('id_festival', isEqualTo: widget.festivalId.trim())
              .where('stage', isEqualTo: widget.stageName)
              .where('date', isEqualTo: currentDate)
              .get();

      print('Artistas encontrados: ${querySnapshot.docs.length}');

      final List<Artist> allArtists =
          querySnapshot.docs.map((doc) {
            final data = doc.data();
            return Artist.fromJson({...data, 'id': doc.id});
          }).toList();

      // Separar por time
      final withTime = allArtists.where((a) => a.time != null).toList();
      final withoutTime = allArtists.where((a) => a.time == null).toList();

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

      final favs = await favoriteService.getFavoritesForFestival(
        widget.festivalId,
      );
      final favIds = favs.map((doc) => doc['artistId'] as String).toSet();

      setState(() {
        artists = [...withTime, ...withoutTime];
        favoriteArtistIds = favIds;
        isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _changeDate(int newIndex) {
    setState(() => currentDateIndex = newIndex);
    loadArtists();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StageAppBar(
        stage: widget.stageName,
        dates: widget.dates,
        currentIndex: currentDateIndex,
        onDateChanged: _changeDate,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : artists.isEmpty
              ? const Center(child: Text('No hay artistas disponibles.'))
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
                        festivalId: widget.festivalId,
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
