class Artist {
  final String id;
  final String name;
  final String date;
  final String? time;
  final String? genre;
  final String? stage;
  final int? duration;
  final String? imageUrl; // nuevo campo opcional para la imagen

  Artist({
    required this.id,
    required this.name,
    required this.date,
    this.time,
    this.genre,
    this.stage,
    this.duration,
    this.imageUrl,
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      date: json['date'] ?? '',
      time: json['time'],
      genre: json['genre'],
      stage: json['stage'],
      duration: json['duration'] as int?,
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'time': time,
      'genre': genre,
      'stage': stage,
      'duration': duration,
      'imageUrl': imageUrl,
    };
  }

  static List<Artist> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => Artist.fromJson(json as Map<String, dynamic>)).toList();
  }

  static List<Map<String, dynamic>> listToJson(List<Artist> artists) {
    return artists.map((artist) => artist.toJson()).toList();
  }
}
