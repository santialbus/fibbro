import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/artist.dart';

class SouthBeachPage extends StatefulWidget {
  const SouthBeachPage({super.key});

  @override
  State<SouthBeachPage> createState() => _SouthBeachPageState();
}

class _SouthBeachPageState extends State<SouthBeachPage> {
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
              .where((artist) => artist.stage == 'South Beach')
              .toList();

      print('Artistas cargados: ${filteredArtists.length}');

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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }
    if (artists.isEmpty) {
      return const Center(child: Text('No hay artistas para South Beach Club'));
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
