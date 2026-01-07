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

static Future<List<FestivalArtistDomain>> getArtistsByIdsAndFestivalId({
  required List<String> artistIds,
  required String festivalId,
}) async {
  if (artistIds.isEmpty) return [];

  final ids = artistIds.take(10).toList();

  final afSnapshot = await FirebaseFirestore.instance
      .collection('artist_festival')
      .where('festivalId', isEqualTo: festivalId)
      .where('artistId', whereIn: ids)
      .orderBy('order')
      .get();

  if (afSnapshot.docs.isEmpty) return [];

  final artistFestivals = afSnapshot.docs
      .map((doc) => ArtistFestival.fromJson({...doc.data(), 'id': doc.id}))
      .toList();

  // 2️⃣ artists
  final artistsSnapshot = await FirebaseFirestore.instance
      .collection('artists')
      .where(FieldPath.documentId, whereIn: ids)
      .get();

  final artistsById = {
    for (final doc in artistsSnapshot.docs)
      doc.id: Artist.fromJson({...doc.data(), 'id': doc.id}),
  };

  // 3️⃣ merge → DOMAIN
  return artistFestivals
      .map((af) {
        final artist = artistsById[af.artistId];
        if (artist == null) return null;
        return FestivalArtistDomain.from(artist, af);
      })
      .whereType<FestivalArtistDomain>()
      .toList();
}

static Future<List<FestivalArtistDomain>> getArtistsByIds({
  required List<String> artistIds
}) async {
  if (artistIds.isEmpty) return [];

  final ids = artistIds.take(10).toList();

  final afSnapshot = await FirebaseFirestore.instance
      .collection('artist_festival')
      .where('artistId', whereIn: ids)
      .get();

  if (afSnapshot.docs.isEmpty) return [];

  final artistFestivals = afSnapshot.docs
      .map((doc) => ArtistFestival.fromJson({...doc.data(), 'id': doc.id}))
      .toList();

  // 2️⃣ artists
  final artistsSnapshot = await FirebaseFirestore.instance
      .collection('artists')
      .where(FieldPath.documentId, whereIn: ids)
      .get();

  final artistsById = {
    for (final doc in artistsSnapshot.docs)
      doc.id: Artist.fromJson({...doc.data(), 'id': doc.id}),
  };

  // 3️⃣ merge → DOMAIN
  return artistFestivals
      .map((af) {
        final artist = artistsById[af.artistId];
        if (artist == null) return null;
        return FestivalArtistDomain.from(artist, af);
      })
      .whereType<FestivalArtistDomain>()
      .toList();
}


  
}
