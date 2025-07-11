import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }
}
