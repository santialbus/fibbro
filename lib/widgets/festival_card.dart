import 'package:flutter/material.dart';

class FestivalCard extends StatelessWidget {
  final String name;
  final String year;
  final List<String> dates;
  final String city;
  final String country;
  final String? imageUrl;
  final List<String> stageNames;
  final VoidCallback? onTap;
  final int? followersCount;
  final List<String>? genres;
  final bool hasMap;

  const FestivalCard({
    super.key,
    required this.name,
    required this.year,
    required this.dates,
    required this.city,
    required this.country,
    this.imageUrl,
    required this.stageNames,
    this.onTap,
    required this.hasMap,
    this.followersCount,
    this.genres,
  });

  String get dateRange {
    if (dates.isEmpty) return '';
    return '${dates.first} - ${dates.last}';
  }

  @override
  Widget build(BuildContext context) {
    final imageWidget =
        (imageUrl != null && imageUrl!.isNotEmpty)
            ? Image.network(imageUrl!, width: 80, height: 80, fit: BoxFit.cover)
            : Image.asset(
              'assets/images/default.png',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            );

    return InkWell(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: imageWidget,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$name - $year',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateRange,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$city, $country',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 6),
                        if (followersCount != null)
                          Text(
                            '👥 $followersCount personas lo siguen',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        if (hasMap)
                          const Text(
                            '📍 Mapa disponible',
                            style: TextStyle(color: Colors.green),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (genres != null && genres!.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: -4,
                  children: [
                    // Mostrar hasta 3 géneros
                    ...genres!
                        .take(3)
                        .map(
                          (genre) => GestureDetector(
                            onTap: () {
                              // Aquí puedes activar el filtro por género
                              debugPrint('Filtro por género: $genre');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Filtrando por: $genre'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            child: Chip(
                              label: Text(
                                genre,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                              ),
                              backgroundColor: Colors.purple.shade50,
                            ),
                          ),
                        ),
                    if (genres!.length > 3)
                      Tooltip(
                        message: genres!.skip(3).join(', '),
                        child: Chip(
                          label: Text(
                            '+${genres!.length - 3} más',
                            style: const TextStyle(fontSize: 12, color: Colors.black),
                          ),
                          backgroundColor: Colors.grey.shade300,
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
