import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/artist.dart';

class HeinekenStagePage extends StatefulWidget {
  const HeinekenStagePage({super.key});

  @override
  State<HeinekenStagePage> createState() => _HeinekenStagePageState();
}

class _HeinekenStagePageState extends State<HeinekenStagePage> {
  List<Artist> artists = [];
  bool isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    loadArtists();
  }

  Future<void> loadArtists() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/docs/artists.json',
      );
      final List<dynamic> jsonData = json.decode(jsonString);

      final filteredArtists =
          jsonData
              .map((json) => Artist.fromJson(json))
              .where((artist) => artist.stage == 'Heineken')
              .toList();

      filteredArtists.sort((a, b) {
        final timeA = _getSortableHour(a.time);
        final timeB = _getSortableHour(b.time);
        return timeA.compareTo(timeB);
      });

      setState(() {
        artists = filteredArtists;
        isLoading = false;
        _errorMessage = null;
      });
    } catch (e, stack) {
      print('Error cargando artistas: $e');
      print(stack);
      setState(() {
        isLoading = false;
        _errorMessage = 'Error cargando artistas';
      });
    }
  }

  int _getSortableHour(String? time) {
    if (time == null) return 9999;
    final parts = time.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    final timeInt = hour * 60 + minute;

    // Si la hora es menor a 6:00 (360 min), se considera después de las 18:00
    return (timeInt < 360) ? timeInt + 1440 : timeInt;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) return Center(child: Text(_errorMessage!));
    if (artists.isEmpty) {
      return const Center(child: Text('No hay artistas para Heineken Stage'));
    }

    return ListView.builder(
      itemCount: artists.length,
      itemBuilder: (context, index) {
        final artist = artists[index];
        return ListTile(
          title: Text(artist.name),
          subtitle: Text(
            '${artist.date} - ${artist.time ?? "Hora no disponible"} (${artist.genre ?? "Género no disponible"})',
          ),
        );
      },
    );
  }
}
