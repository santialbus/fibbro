class Artist {
  final String id;
  final String name;
  final String date;
  final String? time;
  final String? genre;
  final String? stage;
  final int? duration;

  Artist({
    required this.id,
    required this.name,
    required this.date,
    required this.time,
    required this.genre,
    required this.stage,
    required this.duration,
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['id'],
      name: json['name'],
      date: json['date'],
      time: json['time'],
      genre: json['genre'],
      stage: json['stage'],
      duration: json['duration'] as int?,
    );
  }
}
