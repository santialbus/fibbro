import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';  // Para Firestore
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Función simple para leer un documento de Firestore (colección 'test', doc 'sample')
  Future<String> fetchTestData() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('test').doc('sample').get();
      if (doc.exists) {
        return doc.data()?['message'] ?? 'No message field';
      } else {
        return 'Documento no encontrado';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Test',
      home: Scaffold(
        appBar: AppBar(title: const Text('Test Firebase')),
        body: Center(
          child: FutureBuilder<String>(
            future: fetchTestData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return Text('Resultado: ${snapshot.data}');
              }
            },
          ),
        ),
      ),
    );
  }
}
