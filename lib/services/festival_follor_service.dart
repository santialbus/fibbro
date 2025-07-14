import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FestivalFollowService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> toggleFestivalFollow(String festivalId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final docRef = _firestore
        .collection('festivals')
        .doc(festivalId)
        .collection('followers')
        .doc(uid);

    final doc = await docRef.get();

    if (doc.exists) {
      // Eliminar follow
      await docRef.delete();
      await _firestore.collection('festivals').doc(festivalId).update({
        'followersCount': FieldValue.increment(-1),
      });
    } else {
      // Añadir follow
      await docRef.set({
        'uid': uid,
        'followedAt': FieldValue.serverTimestamp(),
      });
      await _firestore.collection('festivals').doc(festivalId).update({
        'followersCount': FieldValue.increment(1),
      });
    }
  }

  Future<bool> isFollowing(String festivalId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;

    final doc =
        await _firestore
            .collection('festivales')
            .doc(festivalId)
            .collection('followers')
            .doc(uid)
            .get();

    return doc.exists;
  }
}
