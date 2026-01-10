// lib/screens/search_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/services/festival_service.dart';
import 'package:myapp/widgets/festival_card.dart';

import '../domain/genre_domain.dart';

class SearchPage extends StatelessWidget {
  final String searchQuery;
  final Function(String) onGenreSelected;

  const SearchPage({
    super.key,
    required this.searchQuery,
    required this.onGenreSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // Usamos un Stack por si quieres poner la barra de búsqueda
      // flotando encima de los resultados más adelante
      body: searchQuery.isEmpty
          ? _buildGenreGrid()
          : _buildSearchResults(),
    );
  }

  Widget _buildGenreGrid() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 80, 20, 20),
            child: Text(
              "Explorar todo",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: -1,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6, // Proporción similar a la captura
            ),
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final genre = appleGenres[index];
                return GestureDetector(
                  onTap: () => onGenreSelected(genre.title),
                  child: Container(
                    clipBehavior: Clip.antiAlias, // Importante para redondear la imagen
                    decoration: BoxDecoration(
                      color: genre.color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Stack(
                      children: [
                        // --- LA IMAGEN CON EFECTO ---
                        Positioned.fill(
                          child: ShaderMask(
                            // Esto ayuda a que el color se mezcle aún mejor
                            shaderCallback: (rect) {
                              return LinearGradient(
                                colors: [genre.color.withOpacity(0.3), genre.color],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(rect);
                            },
                            blendMode: BlendMode.dstIn,
                          ),
                        ),
                        // --- EL TEXTO ---
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              genre.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    blurRadius: 4,
                                    color: Colors.black26,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: appleGenres.length,
            ),
          ),
        ),
        // Espaciado final para que la barra de búsqueda no tape el contenido
        const SliverToBoxAdapter(child: SizedBox(height: 150)),
      ],
    );
  }

  Widget _buildSearchResults() {
    final FestivalService festivalService = FestivalService();
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: festivalService.getFestivalsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final query = searchQuery.toLowerCase();
        final docs = snapshot.data!.docs.where((doc) {
          final data = doc.data();
          final name = (data['name'] ?? '').toString().toLowerCase();
          final genres = List<String>.from(data['genres'] ?? []).map((g) => g.toLowerCase());
          return name.contains(query) || genres.any((g) => g.contains(query));
        }).toList();

        if (docs.isEmpty) {
          return const Center(child: Text("No se encontraron festivales", style: TextStyle(color: Colors.white)));
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 100, bottom: 120),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data();
            return FestivalCard(
              name: data['name'] ?? '',
              year: data['year'] ?? '',
              dates: List<String>.from(data['dates'] ?? []),
              city: data['city'] ?? '',
              country: data['country'] ?? '',
              stageNames: List<String>.from(data['stages'] ?? []),
              imageUrl: data['imageUrl'] ?? '',
              followersCount: data['followersCount'] ?? 0,
              genres: List<String>.from(data['genres'] ?? []),
              hasMap: (data['mapUrl'] ?? '').toString().isNotEmpty,
              isFollowing: false,
              onToggleFollow: () {},
              onTap: () {},
            );
          },
        );
      },
    );
  }
}