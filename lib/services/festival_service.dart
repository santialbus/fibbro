import 'package:cloud_firestore/cloud_firestore.dart';

class FestivalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> getFestivalsStream() {
    return _firestore.collection('festivales').snapshots();
  }

  // Si más adelante quieres agregar funciones como obtener por id, filtrar, etc., aquí se ponen.
}
