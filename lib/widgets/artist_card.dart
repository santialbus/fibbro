import 'package:flutter/material.dart';
import '../models/artist.dart';

class ArtistCard extends StatefulWidget {
  final Artist artist;
  final bool initiallyFavorite;
  final void Function(bool) onFavoriteChanged;

  const ArtistCard({
    super.key,
    required this.artist,
    required this.initiallyFavorite,
    required this.onFavoriteChanged,
  });

  @override
  State<ArtistCard> createState() => _ArtistCardState();
}

class _ArtistCardState extends State<ArtistCard>
    with SingleTickerProviderStateMixin {
  late bool isFavorite;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.initiallyFavorite;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
      lowerBound: 0.7,
      upperBound: 1.0,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    if (isFavorite) {
      _controller.value = 1.0;
    } else {
      _controller.value = 0.7;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? getEndTime(String? startTime, int? duration) {
    if (startTime == null || duration == null) return null;
    final parts = startTime.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);

    final startDateTime = DateTime(0, 1, 1, hour, minute);
    final endDateTime = startDateTime.add(Duration(minutes: duration));

    String twoDigits(int n) => n.toString().padLeft(2, '0');

    return '${twoDigits(endDateTime.hour)}:${twoDigits(endDateTime.minute)}';
  }

  void _toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });
    if (isFavorite) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    widget.onFavoriteChanged(isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    final artist = widget.artist;
    final endTime = getEndTime(artist.time, artist.duration);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: Colors.deepPurpleAccent.withOpacity(0.4),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Acción al tocar la tarjeta si quieres
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Imagen por defecto fija
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/default.png',
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),

              // Información artista
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      artist.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${artist.time ?? "Hora no disponible"}'
                      '${endTime != null ? " - $endTime" : ""}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      artist.genre ?? "Género no disponible",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

              // Botón favorito animado
              ScaleTransition(
                scale: _scaleAnimation,
                child: IconButton(
                  iconSize: 32,
                  icon: Icon(
                    isFavorite ? Icons.star : Icons.star_border,
                    color: isFavorite ? Colors.amber[700] : Colors.grey[500],
                    shadows:
                        isFavorite
                            ? [
                              Shadow(
                                color: Colors.amber.withOpacity(0.6),
                                blurRadius: 8,
                                offset: const Offset(0, 0),
                              ),
                            ]
                            : null,
                  ),
                  onPressed: _toggleFavorite,
                  splashRadius: 28,
                  tooltip:
                      isFavorite ? 'Quitar de favoritos' : 'Añadir a favoritos',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
