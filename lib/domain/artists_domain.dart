import 'package:myapp/models/artist.dart';
import 'package:myapp/models/artist_festival.dart';

class FestivalArtist {
  // Datos de Artist
  final String id;           // id del artista
  final String name;
  final String genre;
  final String? imageUrl;

  // Datos de ArtistFestival
  final String festivalId;
  final String stage;
  final String festivalDay;
  final String realDate;
  final int dayIndex;
  final int startMinutes;
  final int endMinutes;
  final String startTime;
  final int duration;
  final int order;

  FestivalArtist({
    required this.id,
    required this.name,
    required this.genre,
    this.imageUrl,
    required this.festivalId,
    required this.stage,
    required this.festivalDay,
    required this.realDate,
    required this.dayIndex,
    required this.startMinutes,
    required this.endMinutes,
    required this.startTime,
    required this.duration,
    required this.order,
  });

  factory FestivalArtist.from(Artist artist, ArtistFestival af) {
    return FestivalArtist(
      id: artist.id,
      name: artist.name,
      genre: artist.genre,
      imageUrl: artist.imageUrl,
      festivalId: af.festivalId,
      stage: af.stage,
      festivalDay: af.festivalDay,
      realDate: af.realDate,
      dayIndex: af.dayIndex,
      startMinutes: af.startMinutes,
      endMinutes: af.endMinutes,
      startTime: af.startTime,
      duration: af.duration,
      order: af.order,
    );
  }
}
