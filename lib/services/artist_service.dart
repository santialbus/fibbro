// lib/services/artist_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/domain/artists_domain.dart';
import 'package:myapp/models/artist.dart';
import 'package:myapp/models/artist_festival.dart';

class ArtistService {

  static Future<List<FestivalArtistDomain>> getArtistsForStageNew({
    required String festivalId,
    required String festivalDate,
    required String stage,
  }) async {
    // 1️⃣ Query artist_festival
    final afSnapshot =
        await FirebaseFirestore.instance
            .collection('artist_festival')
            .where('festivalId', isEqualTo: festivalId)
            .where('festivalDate', isEqualTo: festivalDate)
            .where('stage', isEqualTo: stage)
            .orderBy('order')
            .get();
    if (afSnapshot.docs.isEmpty) {
      return [];
    }

    final artistFestivals =
        afSnapshot.docs
            .map(
              (doc) => ArtistFestival.fromJson({...doc.data(), 'id': doc.id}),
            )
            .toList();
    final artistIds = artistFestivals.map((af) => af.artistId).toSet().toList();

    if (artistIds.isEmpty) {
      return [];
    }
    final artistsSnapshot =
        await FirebaseFirestore.instance
            .collection('artists')
            .where(FieldPath.documentId, whereIn: artistIds)
            .get();
    final artistsById = {
      for (final doc in artistsSnapshot.docs)
        doc.id: Artist.fromJson({...doc.data(), 'id': doc.id}),
    };
    final result = <FestivalArtistDomain>[];

    for (final af in artistFestivals) {
      final artist = artistsById[af.artistId];
      if (artist == null) continue;

      result.add(FestivalArtistDomain.from(artist, af));
    }

    return result;
  }
}
