import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:myapp/screens/festival_page.dart';
import 'package:myapp/services/festival_follor_service.dart';
import 'package:myapp/services/festival_service.dart';
import 'package:myapp/widgets/festival_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final FestivalService _festivalService = FestivalService();
  final FestivalFollowService _followService = FestivalFollowService();

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final Map<String, bool> _followingStatus = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 🔍 MISMA LÓGICA DE FILTRADO QUE TENÍAS EN HOME
  List<DocumentSnapshot<Map<String, dynamic>>> _filteredDocs(
      List<DocumentSnapshot<Map<String, dynamic>>> docs) {
    if (_searchQuery.isEmpty) return docs;

    final query = _searchQuery.toLowerCase();
    return docs.where((doc) {
      final data = doc.data();
      if (data == null) return false;

      final name = (data['name'] ?? '').toString().toLowerCase();
      final city = (data['city'] ?? '').toString().toLowerCase();
      final country = (data['country'] ?? '').toString().toLowerCase();
      final genres =
      List<String>.from(data['genres'] ?? []).map((g) => g.toLowerCase());

      return name.contains(query) ||
          city.contains(query) ||
          country.contains(query) ||
          genres.any((g) => g.contains(query));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Buscar festivales...',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() => _searchQuery = value);
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _festivalService.getFestivalsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar festivales'));
          }

          final docs = _filteredDocs(snapshot.data?.docs ?? []);

          if (docs.isEmpty) {
            return const Center(child: Text('Sin resultados'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data()!;
              final festivalId = doc.id;

              return FestivalCard(
                name: data['name'],
                year: data['year'],
                dates: List<String>.from(data['dates'] ?? []),
                city: data['city'],
                country: data['country'],
                stageNames: List<String>.from(data['stages'] ?? []),
                imageUrl: data['imageUrl'],
                followersCount: data['followersCount'],
                genres: List<String>.from(data['genres'] ?? []),
                hasMap: (data['mapUrl'] ?? '').toString().isNotEmpty,
                isFollowing: _followingStatus[festivalId] ?? false,
                onToggleFollow: () async {
                  await _followService.toggleFestivalFollow(festivalId);
                  final isFollowing =
                  await _followService.isFollowing(festivalId);
                  if (mounted) {
                    setState(() {
                      _followingStatus[festivalId] = isFollowing;
                    });
                  }
                },
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FestivalPage(
                        festivalId: festivalId,
                        festivalName: data['name'],
                        stageNames:
                        List<String>.from(data['stageNames'] ?? []),
                        dates: List<String>.from(data['dates'] ?? []),
                      ),
                    ),
                  );
                },
                onGenreTap: (genre) {
                  setState(() {
                    _searchQuery = genre;
                    _searchController.text = genre;
                  });
                },
              );
            },
          );
        },
      ),
    );
  }
}
