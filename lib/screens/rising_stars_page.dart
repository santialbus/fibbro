// rising_stars_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/artist.dart';

class RisingStarsPage extends StatefulWidget {
  const RisingStarsPage({super.key});

  @override
  State<RisingStarsPage> createState() => _RisingStarsPageState();
}

class _RisingStarsPageState extends State<RisingStarsPage> {
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
              .where((artist) => artist.stage == 'Rising Stars')
              .toList();

      filteredArtists.sort((a, b) {
        return _getSortableHour(a.time).compareTo(_getSortableHour(b.time));
      });

      setState(() {
        artists = filteredArtists;
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

  int _getSortableHour(String? time) {
    if (time == null) return 9999;
    final parts = time.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    final totalMinutes = hour * 60 + minute;
    return totalMinutes < 360 ? totalMinutes + 1440 : totalMinutes;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) return Center(child: Text(_errorMessage!));
    if (artists.isEmpty) {
      return const Center(child: Text('No hay artistas para Rising Stars'));
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
