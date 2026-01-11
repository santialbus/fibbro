import 'package:flutter/material.dart';

import '../../domain/genre_domain.dart';

Widget _buildGenreCard(Genre genre) {
  return Container(
    decoration: BoxDecoration(
      color: genre.color,
      borderRadius: BorderRadius.circular(12),
      // Si tienes imágenes, puedes usar DecorationImage con un filtro de color
    ),
    padding: const EdgeInsets.all(16),
    child: Align(
      alignment: Alignment.bottomLeft,
      child: Text(
        genre.title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
    ),
  );
}