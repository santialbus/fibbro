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

  Future<void> loadArtists() async {
    setState(() => isLoading = true);

    try {
      // 1. Obtener el festival
      final festivalDoc =
          await FirebaseFirestore.instance
              .collection('festivales')
              .doc(widget.festivalId)
              .get();

      if (!festivalDoc.exists) throw Exception('Festival no encontrado');

      // Imprimir los datos del festival para ver estructura
      print('Datos festival: ${festivalDoc.data()}');

      // Confirmar que el campo es 'artistIds' o el correcto:
      final List<dynamic>? artistIdsDynamic = festivalDoc.data()?['artistIds'];
      if (artistIdsDynamic == null) {
        throw Exception('Campo artistIds no encontrado en el festival');
      }

      // Pasar a List<String> asegurando que sean strings
      final List<String> artistIds =
          artistIdsDynamic.map((e) => e.toString()).toList();

      print('IDs artistas del festival: $artistIds');

      if (artistIds.isEmpty) {
        setState(() {
          artists = [];
          isLoading = false;
        });
        return;
      }

      final String currentDate = widget.dates[currentDateIndex];
      print('Fecha actual seleccionada: $currentDate');

      // 2. Obtener artistas filtrados por ID, stage y date
      // Recuerda que Firebase limita a 10 IDs en whereIn
      final limitedIds = artistIds.take(10).toList();

      print('IDs usados en consulta artists: $limitedIds');

      final artistQuery = FirebaseFirestore.instance
          .collection('artists')
          .where(FieldPath.documentId, whereIn: limitedIds);

      final artistDocs = await artistQuery.get();

      print('Número de artistas recuperados: ${artistDocs.docs.length}');

      final filteredArtists =
          artistDocs.docs
              .map((doc) {
                final data = doc.data();
                return Artist.fromJson({...data, 'id': doc.id});
              })
              .where(
                (artist) =>
                    artist.stage == widget.stageName &&
                    artist.date == currentDate,
              )
              .toList();

      print('Artistas filtrados por stage y fecha: ${filteredArtists.length}');

      // ... ordenación igual que antes

      // Obtener favoritos y setState igual que antes
      // ...
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
        //_errorMessage = e.toString();
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
