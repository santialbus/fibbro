class Artist {
  final String id;
  final String name;
  final String? imageUrl;
  final String genre;

  Artist({required this.id, required this.name, this.imageUrl, required this.genre});

  factory Artist.fromJson(Map<String, dynamic> json) => Artist(
    id: json['id'] as String,
    name: json['name'] as String,
    imageUrl: json['imageUrl'] as String?,
    genre: json['genre'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'imageUrl': imageUrl,
    'genre': genre,
  };

  static List<Artist> listFromJson(List<dynamic> list) =>
      list.map((e) => Artist.fromJson(e)).toList();

  static List<Map<String, dynamic>> listToJson(List<Artist> list) =>
      list.map((e) => e.toJson()).toList();
}
