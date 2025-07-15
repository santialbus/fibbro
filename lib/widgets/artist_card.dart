import 'package:flutter/material.dart';
import '../models/artist.dart';

class ArtistCard extends StatelessWidget {
  final Artist artist;
  final bool initiallyFavorite;
  final void Function(bool) onFavoriteChanged;
  final bool showAlert;
  final List<Artist> overlappingArtists;

  const ArtistCard({
    super.key,
    required this.artist,
    required this.initiallyFavorite,
    required this.onFavoriteChanged,
    this.showAlert = false,
    this.overlappingArtists = const [],
  });

  String? getEndTime(String? startTime, int? duration) {
    if (startTime == null || duration == null) return null;
    final parts = startTime.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);

    final start = DateTime(0, 1, 1, hour, minute);
    final end = start.add(Duration(minutes: duration));

    return '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final endTime = getEndTime(artist.time, artist.duration);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading:
            artist.imageUrl != null && artist.imageUrl!.isNotEmpty
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.network(
                    artist.imageUrl!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                )
                : CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey.shade300,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
        title: Text(
          artist.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (artist.time != null)
              Text('${artist.time}${endTime != null ? ' - $endTime' : ''}'),
            if (artist.genre != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  artist.genre!,
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.deepPurpleAccent,
                  ),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showAlert && overlappingArtists.isNotEmpty)
              Tooltip(
                message:
                    'Solapa con: ${overlappingArtists.map((a) => a.name).join(', ')}',
                child: const Icon(Icons.error_outline, color: Colors.redAccent),
              ),
            IconButton(
              icon: Icon(
                initiallyFavorite ? Icons.favorite : Icons.favorite_border,
                color: Colors.red,
              ),
              onPressed: () => onFavoriteChanged(!initiallyFavorite),
            ),
          ],
        ),
      ),
    );
  }
}
