import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/services/festival_service.dart';
import 'package:myapp/widgets/festival_card.dart';
import '../domain/genre_domain.dart';

class SearchPage extends StatefulWidget {
  final String searchQuery; // Este viene de lo que escribes en la barra
  final Function(String) onGenreSelected;

  const SearchPage({
    super.key,
    required this.searchQuery,
    required this.onGenreSelected,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // Variable interna para manejar el género clickeado localmente
  String? _localGenreQuery;

  @override
  void didUpdateWidget(covariant SearchPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si el usuario empieza a escribir en la barra, limpiamos el filtro de género local
    if (widget.searchQuery != oldWidget.searchQuery && widget.searchQuery.isNotEmpty) {
      _localGenreQuery = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // La búsqueda efectiva es: o lo que escribes, o el género que tocaste
    final effectiveQuery = (_localGenreQuery ?? widget.searchQuery).trim();

    dev.log('🔍 SearchPage: Renderizando con query efectiva = "$effectiveQuery"');

    return Scaffold(
      backgroundColor: Colors.black,
      body: effectiveQuery.isEmpty
          ? _buildGenreGrid()
          : _buildSearchResults(effectiveQuery),
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
                color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1,
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
              childAspectRatio: 1.6,
            ),
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final genre = festivalGenres[index];
                return GestureDetector(
                  onTap: () {
                    dev.log('🖱️ Click en género: ${genre.title}');
                    setState(() {
                      _localGenreQuery = genre.title; // CAMBIO INTERNO: Ahora la página sabe qué buscar
                    });
                    widget.onGenreSelected(genre.title); // Avisamos fuera por si el Navbar necesita actualizarse
                  },
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: genre.color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ShaderMask(
                            shaderCallback: (rect) => LinearGradient(
                              colors: [genre.color.withOpacity(0.3), genre.color],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(rect),
                            blendMode: BlendMode.dstIn,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              genre.title,
                              style: const TextStyle(
                                color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: festivalGenres.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 150)),
      ],
    );
  }

  Widget _buildSearchResults(String activeQuery) {
    final FestivalService festivalService = FestivalService();
    final lowerQuery = activeQuery.toLowerCase();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: festivalService.getFestivalsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }

        final docs = snapshot.data?.docs.where((doc) {
          final data = doc.data();
          final name = (data['name'] ?? '').toString().toLowerCase();
          final city = (data['city'] ?? '').toString().toLowerCase();
          final List<dynamic> genresList = data['genres'] ?? [];
          final genres = genresList.map((g) => g.toString().toLowerCase()).toList();

          return name.contains(lowerQuery) ||
              city.contains(lowerQuery) ||
              genres.any((g) => g.contains(lowerQuery));
        }).toList() ?? [];

        if (docs.isEmpty) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("No hay resultados para '$activeQuery'", style: const TextStyle(color: Colors.white)),
              TextButton(
                onPressed: () => setState(() => _localGenreQuery = null),
                child: const Text("Volver a géneros", style: TextStyle(color: Colors.blue)),
              )
            ],
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 80, bottom: 120),
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
              imageUrl: data['imageUrl'],
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