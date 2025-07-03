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

      // Filtramos los artistas del escenario South Beach con hora válida
      final List<Artist> withTime =
          jsonData
              .map((json) => Artist.fromJson(json))
              .where(
                (artist) =>
                    artist.stage == 'South Beach' && artist.time != null,
              )
              .toList();

      // Ordenar por hora con regla nocturna
      withTime.sort((a, b) {
        int parseHour(String time) {
          final parts = time.split(':');
          int hour = int.parse(parts[0]);
          int minute = int.parse(parts[1]);

          // Si es entre 00:00 y 05:59, lo consideramos +24h
          if (hour < 6) hour += 24;

          return hour * 60 + minute;
        }

        return parseHour(a.time!) - parseHour(b.time!);
      });

      // Artistas sin hora (opcionalmente los puedes añadir al final)
      final List<Artist> withoutTime =
          jsonData
              .map((json) => Artist.fromJson(json))
              .where(
                (artist) =>
                    artist.stage == 'South Beach' && artist.time == null,
              )
              .toList();

      setState(() {
        artists = [
          ...withTime,
          ...withoutTime,
        ]; // primero con hora, luego sin hora
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
