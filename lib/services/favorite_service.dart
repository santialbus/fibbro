import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoriteService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

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
  final favs = await _firestore
      .collection('favorites')
      .where('userId', isEqualTo: userId)
      .where('festivalId', isEqualTo: festivalId)
      .get();

  return favs.docs.map((doc) => doc['artistId'] as String).toList();
}

}
