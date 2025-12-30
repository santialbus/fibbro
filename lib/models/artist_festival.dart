class ArtistFestival {
  final String id;
  final String festivalId;
  final String artistId;
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

  ArtistFestival({
    required this.id,
    required this.festivalId,
    required this.artistId,
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

  factory ArtistFestival.fromJson(Map<String, dynamic> json) {
    return ArtistFestival(
      id: json['id'] as String,
      festivalId: json['festivalId'] as String,
      artistId: json['artistId'] as String,
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'festivalId': festivalId,
      'artistId': artistId,
      'stage': stage,
      'festivalDay': festivalDay,
      'festivalDate': festivalDate,
      'realDate': realDate,
      'dayIndex': dayIndex,
      'startMinutes': startMinutes,
      'endMinutes': endMinutes,
      'startTime': startTime,
      'duration': duration,
      'order': order,
    };
  }
}
