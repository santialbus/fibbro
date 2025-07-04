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

class _ArtistCardState extends State<ArtistCard> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.initiallyFavorite;
  }

  String? getEndTime(String? startTime, int? duration) {
    if (startTime == null || duration == null) return null;
    final parts = startTime.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);

    final startDateTime = DateTime(0, 1, 1, hour, minute);
    final endDateTime = startDateTime.add(Duration(minutes: duration));

    // Formatear a HH:mm, añadiendo cero si es necesario
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    return '${twoDigits(endDateTime.hour)}:${twoDigits(endDateTime.minute)}';
  }

  void _toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });
    widget.onFavoriteChanged(isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(widget.artist.name, style: const TextStyle(fontSize: 18)),
        subtitle: Text(
          '${widget.artist.time ?? "Hora no disponible"}'
          '${widget.artist.duration != null ? " - ${getEndTime(widget.artist.time, widget.artist.duration)}" : ""}\n'
          '${widget.artist.genre ?? "Género no disponible"}',
        ),

        trailing: IconButton(
          icon: Icon(
            isFavorite ? Icons.star : Icons.star_border,
            color: isFavorite ? Colors.amber : null,
          ),
          onPressed: _toggleFavorite,
        ),
      ),
    );
  }
}
