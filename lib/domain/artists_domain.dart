import 'package:myapp/models/artist.dart';
import 'package:myapp/models/artist_festival.dart';

class FestivalArtistDomain {
  // Datos de Artist
  final String id; // id del artista
  final String name;
  final String genre;
  final String? imageUrl;

  // Datos de ArtistFestival
  final String festivalId;
  final String stage;
  final String festivalDay;
  final String festivalDate;
  final String realDate;
  final int dayIndex;
  final int startMinutes;
  final int endMinutes;
  final String startTime;
  final int duration;
  final int order;

  FestivalArtistDomain({
    required this.id,
    required this.name,
    required this.genre,
    this.imageUrl,
    required this.festivalId,
    required this.stage,
    required this.festivalDay,
    required this.festivalDate,
    required this.realDate,
    required this.dayIndex,
    required this.startMinutes,
    required this.endMinutes,
    required this.startTime,
    required this.duration,
    required this.order,
  });

  factory FestivalArtistDomain.from(Artist artist, ArtistFestival af) {
    return FestivalArtistDomain(
      id: artist.id,
      name: artist.name,
      genre: artist.genre,
      imageUrl: artist.imageUrl,
      festivalId: af.festivalId,
      stage: af.stage,
      festivalDay: af.festivalDay,
      festivalDate: af.festivalDate,
      realDate: af.realDate,
      dayIndex: af.dayIndex,
      startMinutes: af.startMinutes,
      endMinutes: af.endMinutes,
      startTime: af.startTime,
      duration: af.duration,
      order: af.order,
    );
  }

  factory FestivalArtistDomain.fromJson(Map<String, dynamic> json) {
  return FestivalArtistDomain(
    id: json['id'] as String,
    name: json['name'] as String,
    genre: json['genre'] as String,
    imageUrl: json['imageUrl'] as String?,
    festivalId: json['festivalId'] as String,
    stage: json['stage'] as String,
    festivalDay: json['festivalDay'] as String,
    festivalDate: json['festivalDate'] as String,
    realDate: json['realDate'] as String,
    dayIndex: json['dayIndex'] as int,
    startMinutes: json['startMinutes'] as int,
    endMinutes: json['endMinutes'] as int,
    startTime: json['startTime'] as String,
    duration: json['duration'] as int,
    order: json['order'] as int,
  );
}

}
