import 'package:cloud_firestore/cloud_firestore.dart';

class FestivalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> getFestivalsStream() {
    return _firestore.collection('festivales').snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getFestivalsByGenre(String genre) {
    return _firestore
        .collection('festivales')
        .where('genres', arrayContains: genre)
        .snapshots();
  }
}
