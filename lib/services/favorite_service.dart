import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:myapp/models/artist.dart';

class FavoriteService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  static const String fibFestivalId = '0e79d8ae-8c29-4f8e-a2bb-3a1eae9d2a77';

  Future<void> toggleFavorite({
    required String artistId,
    required String festivalId,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final favQuery =
        await _firestore
            .collection('favorites')
            .where('userId', isEqualTo: userId)
            .where('artistId', isEqualTo: artistId)
            .where('festivalId', isEqualTo: festivalId)
            .get();

    if (favQuery.docs.isNotEmpty) {
      // Ya es favorito, lo quitamos
      await favQuery.docs.first.reference.delete();
    } else {
      // No es favorito, lo añadimos
      await _firestore.collection('favorites').add({
        'userId': userId,
        'artistId': artistId,
        'festivalId': festivalId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<bool> isFavorite({
    required String artistId,
    required String festivalId,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;

    final favQuery =
        await _firestore
            .collection('favorites')
            .where('userId', isEqualTo: userId)
            .where('artistId', isEqualTo: artistId)
            .where('festivalId', isEqualTo: festivalId)
            .get();

    return favQuery.docs.isNotEmpty;
  }

  Future<void> removeFavorite({
    required String artistId,
    required String festivalId,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final favQuery =
        await _firestore
            .collection('favorites')
            .where('userId', isEqualTo: userId)
            .where('artistId', isEqualTo: artistId)
            .where('festivalId', isEqualTo: festivalId)
            .get();

    for (var doc in favQuery.docs) {
      await doc.reference.delete();
    }
  }

  Future<List<QueryDocumentSnapshot>> getFavoritesForFestival(
    String festivalId,
  ) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    final favQuery =
        await _firestore
            .collection('favorites')
            .where('userId', isEqualTo: userId)
            .where('festivalId', isEqualTo: festivalId)
            .get();

    return favQuery.docs;
  }

  Future<List<String>> getFavoriteArtistIdsForUser({
    required String userId,
    required String festivalId,
  }) async {
    final favs =
        await _firestore
            .collection('favorites')
            .where('userId', isEqualTo: userId)
            .where('festivalId', isEqualTo: festivalId)
            .get();

    return favs.docs.map((doc) => doc['artistId'] as String).toList();
  }

  /// Obtiene todos los artistas favoritos con datos completos para un usuario
  Future<List<Artist>> getFavoriteArtistsForUser(String userId) async {
    // 1. Obtener todos los favoritos de este usuario (artistId + festivalId)
    final favSnapshot =
        await _firestore
            .collection('favorites')
            .where('userId', isEqualTo: userId)
            .get();

    if (favSnapshot.docs.isEmpty) return [];

    // Map<festivalId, List<artistId>>
    Map<String, List<String>> festivalToArtistIds = {};

    for (var doc in favSnapshot.docs) {
      final data = doc.data();
      final festivalId = data['festivalId'] as String? ?? '';
      final artistId = data['artistId'] as String? ?? '';
      if (festivalId.isEmpty || artistId.isEmpty) continue;

      festivalToArtistIds.putIfAbsent(festivalId, () => []);
      festivalToArtistIds[festivalId]!.add(artistId);
    }

    List<Artist> result = [];

    // 2. Por cada festival, cargar los artistas
    for (final entry in festivalToArtistIds.entries) {
      final festivalId = entry.key;
      final artistIds = entry.value;

      if (festivalId == fibFestivalId) {
        // Carga desde JSON local para FIB
        final jsonString = await rootBundle.loadString(
          'assets/docs/artists.json',
        );
        final jsonData = json.decode(jsonString) as List;
        final allArtists = jsonData.map((e) => Artist.fromJson(e)).toList();

        final fibArtists =
            allArtists.where((a) => artistIds.contains(a.id)).toList();
        result.addAll(fibArtists);
      } else {
        // Carga desde Firebase para otros festivales
        // Aquí consultamos artistas donde el festivalId es igual y el id está en artistIds
        final artistsQuery =
            await _firestore
                .collection('artists')
                .where('id_festival', isEqualTo: festivalId)
                .where(
                  FieldPath.documentId,
                  whereIn: artistIds.take(10).toList(),
                ) // Por batch si quieres
                .get();

        final firebaseArtists =
            artistsQuery.docs
                .map((doc) => Artist.fromJson({...doc.data(), 'id': doc.id}))
                .toList();

        result.addAll(firebaseArtists);
      }
    }

    return result;
  }
}
