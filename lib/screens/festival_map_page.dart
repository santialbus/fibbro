import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/utils/app_logger.dart';

class FestivalMapPage extends StatefulWidget {
  final String festivalId;

  const FestivalMapPage({super.key, required this.festivalId});

  @override
  State<FestivalMapPage> createState() => _FestivalMapPageState();
}

class _FestivalMapPageState extends State<FestivalMapPage> {
  String? mapUrl;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    AppLogger.page('FestivalMapPage');
    _loadMapUrl();
  }

  Future<void> _loadMapUrl() async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('festivales')
              .doc(widget.festivalId)
              .get();

      if (doc.exists &&
          doc.data() != null &&
          doc.data()!.containsKey('mapUrl')) {
        setState(() {
          mapUrl = doc['mapUrl'] as String;
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'No se encontró mapa para este festival.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error al cargar el mapa: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa del recinto')),
      body: Center(
        child:
            isLoading
                ? const CircularProgressIndicator()
                : error != null
                ? Text(error!)
                : InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.network(mapUrl!, fit: BoxFit.contain),
                ),
      ),
    );
  }
}
