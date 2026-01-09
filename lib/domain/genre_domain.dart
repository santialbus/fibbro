import 'dart:ui';

class Genre {
  final String title;
  final Color color;
  final String? imageUrl;

  Genre({required this.title, required this.color, this.imageUrl});
}

final List<Genre> appleGenres = [
  Genre(title: "Radio", color: const Color(0xFFE91E63)),
  Genre(title: "Navidad", color: const Color(0xFFB71C1C)),
  Genre(title: "Audio espacial", color: const Color(0xFFEF5350)),
  Genre(title: "Pop en español", color: const Color(0xFF9575CD)),
  Genre(title: "Flamenco", color: const Color(0xFFEC407A)),
  Genre(title: "Rock en español", color: const Color(0xFFFB8C00)),
  Genre(title: "Listas", color: const Color(0xFF9E9D24)),
  Genre(title: "Música catalana", color: const Color(0xFFE65100)),
  Genre(title: "Canta", color: const Color(0xFFF06292)),
  Genre(title: "Apple Music Classical", color: const Color(0xFFE57373)),
];