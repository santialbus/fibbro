import 'dart:ui';

class Genre {
  final String title;
  final Color color;
  final String? imageUrl;

  Genre({required this.title, required this.color, this.imageUrl});
}

final List<Genre> festivalGenres = [
  // --- ROCK & METAL ---
  Genre(title: "Rock", color: const Color(0xFFD32F2F)),         // Rojo Intenso
  Genre(title: "Heavy Metal", color: const Color(0xFF212121)),  // Negro/Gris Carbón
  Genre(title: "Thrash Metal", color: const Color(0xFF37474F)), // Gris Azulado oscuro
  Genre(title: "Indie Rock", color: const Color(0xFF00796B)),   // Verde Azulado
  Genre(title: "Punk Rock", color: const Color(0xFFC62828)),    // Rojo Sangre
  Genre(title: "Alternative", color: const Color(0xFF6A1B9A)),  // Púrpura Profundo

  // --- ELECTRÓNICA ---
  Genre(title: "Techno", color: const Color(0xFF1A237E)),       // Azul Eléctrico
  Genre(title: "House", color: const Color(0xFF00BCD4)),        // Cian
  Genre(title: "EDM", color: const Color(0xFFFFD600)),          // Amarillo Neón
  Genre(title: "Hardstyle", color: const Color(0xFFBF360C)),    // Naranja Quemado
  Genre(title: "Drum & Bass", color: const Color(0xFF4E342E)),  // Marrón oscuro
  Genre(title: "Deep House", color: const Color(0xFF0D47A1)),   // Azul Cobalto

  // --- URBAN & POP ---
  Genre(title: "Reggaeton", color: const Color(0xFFF44336)),    // Rojo Urbano
  Genre(title: "Trap", color: const Color(0xFF9C27B0)),         // Morado Trap
  Genre(title: "Hip Hop", color: const Color(0xFFFF6F00)),      // Ámbar intenso
  Genre(title: "Pop", color: const Color(0xFFE91E63)),          // Rosa Pop
  Genre(title: "Dancehall", color: const Color(0xFF2E7D32)),    // Verde Selva

  // --- OTROS / EXPERIENCIAS ---
  Genre(title: "Jazz & Blues", color: const Color(0xFF455A64)), // Azul Grisáceo
  Genre(title: "Folk", color: const Color(0xFF8D6E63)),         // Tierra
  Genre(title: "Reggae", color: const Color(0xFF388E3C)),       // Verde Reggae
  Genre(title: "Psych Rock", color: const Color(0xFFFF4081)),   // Rosa Neón
];