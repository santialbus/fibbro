import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/artist.dart';
import '../widgets/artist_card.dart';
import '../widgets/stage_app_bar.dart';

class CuttySharkPage extends StatefulWidget {
  const CuttySharkPage({super.key});

  @override
  State<CuttySharkPage> createState() => _CuttySharkPageState();
}

class _CuttySharkPageState extends State<CuttySharkPage> {
  List<Artist> artists = [];
  bool isLoading = true;
  String? _errorMessage;

  int _currentDateIndex = 0;
  final List<String> _availableDates = [
    '2025-07-17',
    '2025-07-18',
    '2025-07-19',
  ];

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
                    artist.stage == 'Cutty Shark' &&
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
                    artist.stage == 'Cutty Shark' &&
                    artist.date == currentDate &&
                    artist.time == null,
              )
              .toList();

      setState(() {
        artists = [...withTime, ...withoutTime];
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
        stage: 'Cutty Shark',
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
              ? const Center(child: Text('No hay artistas para Cutty Shark'))
              : ListView.builder(
                itemCount: artists.length,
                itemBuilder: (context, index) {
                  final artist = artists[index];
                  return ArtistCard(
                    artist: artist,
                    initiallyFavorite: false,
                    onFavoriteChanged: (isFav) {
                      print('${artist.name} es favorito: $isFav');
                    },
                  );
                },
              ),
    );
  }
}
