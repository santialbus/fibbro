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
      // <--- para detectar taps y ripple
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageWidget,
            ),
            Container(
              width: 2,
              height: 80,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              color: Colors.grey.shade400,
            ),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
