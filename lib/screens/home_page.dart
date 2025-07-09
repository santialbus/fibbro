import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/screens/festival_page.dart';
import 'package:myapp/services/notification_service.dart';
import 'package:myapp/widgets/festival_card.dart'; // Asegúrate de importar correctamente

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('onStagee'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // De momento inoperativo
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('festivales').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar festivales'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text('No hay festivales disponibles.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return FestivalCard(
                name: (data['name'] ?? '').toString(),
                year: (data['year'] ?? '').toString(),
                dates: List<String>.from(data['date'] ?? []),
                city: (data['ciudad'] ?? '').toString(),
                country: (data['pais'] ?? '').toString(),
                stageNames: List<String>.from(data['stages'] ?? []),
                imageUrl: data['imageUrl'],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => FestivalPage(
                            festivalId:
                                docs[index]
                                    .id, // o data['id'] si lo tienes en el documento
                            festivalName: (data['name'] ?? '').toString(),
                            stageNames: List<String>.from(
                              data['stages'],
                            ), // asegúrate de que es una lista de strings
                            dates: List<String>.from(
                              data['date'],
                            ), // Le pasas toda la info o solo lo que necesites
                          ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await NotificationService().showImmediateNotification();
        },
        child: const Icon(Icons.notifications),
      ),
    );
  }
}
