import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/domain/artists_domain.dart';
import '../models/artist.dart';
import '../models/artist_festival.dart';

class FestivalArtistService {
  static final _firestore = FirebaseFirestore.instance;

  /// Devuelve la lista de FestivalArtist para un festival, stage y día
  static Future<List<FestivalArtist>> getArtistsForStage({
    required String festivalId,
    required String stage,
    required String realDate,
  }) async {
    // 1️⃣ Traemos los ArtistFestival que coincidan
    final afQuery = await _firestore
        .collection('artist_festival')
        .where('festivalId', isEqualTo: festivalId)
        .where('stage', isEqualTo: stage)
        .where('realDate', isEqualTo: realDate)
        .get();

    final afList = afQuery.docs
        .map((doc) => ArtistFestival.fromJson({...doc.data(), 'id': doc.id}))
        .toList();

    if (afList.isEmpty) return [];

    // 2️⃣ Obtenemos los ids de artista
    final artistIds = afList.map((af) => af.artistId).toList();

    // 3️⃣ Traemos los Artist correspondientes
    final batchSize = 10;
    List<Artist> artists = [];

    for (var i = 0; i < artistIds.length; i += batchSize) {
      final batchIds = artistIds.sublist(
        i,
        i + batchSize > artistIds.length ? artistIds.length : i + batchSize,
      );

      if (batchIds.isEmpty) continue;

      final artistQuery = await _firestore
          .collection('artists')
          .where(FieldPath.documentId, whereIn: batchIds)
          .get();

      artists.addAll(
          artistQuery.docs.map((doc) => Artist.fromJson({...doc.data(), 'id': doc.id})));
    }

    // 4️⃣ Combinamos Artist + ArtistFestival en FestivalArtist
    final festivalArtists = afList.map((af) {
      final artist = artists.firstWhere((a) => a.id == af.artistId);
      return FestivalArtist.from(artist, af);
    }).toList();

    // 5️⃣ Opcional: orden por startMinutes o dayIndex
    festivalArtists.sort((a, b) {
      final dateCompare = a.startMinutes.compareTo(b.startMinutes);
      if (dateCompare != 0) return dateCompare;
      return a.order.compareTo(b.order);
    });

    return festivalArtists;
  }
}
