// lib/screens/search_page.dart
import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/services/festival_service.dart';
import 'package:myapp/widgets/festival_card.dart';
import '../domain/genre_domain.dart';
import 'festival_page.dart';

class SearchPage extends StatefulWidget {
  final String searchQuery;
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
  String? _localGenreQuery;

  @override
  void didUpdateWidget(covariant SearchPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si el texto de la barra superior se borra, volvemos a mostrar los géneros
    if (widget.searchQuery.isEmpty && oldWidget.searchQuery.isNotEmpty) {
      _localGenreQuery = null;
    }
    // Si el usuario escribe algo nuevo en la barra, priorizamos eso sobre el género seleccionado
    if (widget.searchQuery != oldWidget.searchQuery && widget.searchQuery.isNotEmpty) {
      _localGenreQuery = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveQuery = (_localGenreQuery ?? widget.searchQuery).trim();
    final bool isViewingResults = effectiveQuery.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.black,
      // Solo mostramos el AppBar si hay algo buscado (estilo Apple Music)
      appBar: isViewingResults
          ? AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: false, // Alineado a la izquierda como en tu captura
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () {
            setState(() => _localGenreQuery = null);
            widget.onGenreSelected(''); // Limpiamos la búsqueda global
          },
        ),
        title: Text(
          effectiveQuery,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold
          ),
        ),
      )
          : null,
      body: !isViewingResults
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
              style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1),
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
                    setState(() => _localGenreQuery = genre.title);
                    widget.onGenreSelected(genre.title); // Sincroniza con el Nav Bar
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
                              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
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

          return name.contains(lowerQuery) || city.contains(lowerQuery) || genres.any((g) => g.contains(lowerQuery));
        }).toList() ?? [];

        if (docs.isEmpty) {
          return Center(
            child: Text("No hay resultados para '$activeQuery'", style: const TextStyle(color: Colors.grey)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 20, bottom: 120),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data();
            // Extraemos el ID del documento por si lo necesitas en la siguiente página
            final festivalId = docs[index].id;

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
              onToggleFollow: () {
                // Aquí podrías implementar la lógica rápida de seguimiento
              },
              onTap: () {
                // NAVEGACIÓN: Te manda a la página del festival
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FestivalPage(
                      festivalId: festivalId,
                      festivalName: (data['name'] ?? '').toString(),
                      stageNames: List<String>.from(data['stageNames'] ?? []),
                      dates: List<String>.from(data['dates'] ?? []),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}