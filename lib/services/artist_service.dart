// lib/services/artist_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/artist.dart';
import 'package:myapp/utils/date_utils.dart';

class ArtistService {
  static Future<List<Artist>> getArtistsForStage({
    required String festivalId,
    required String stage,
    required String rawDate,
  }) async {
    final date = DateUtilsHelper.normalizeDate(rawDate);

    final querySnapshot = await FirebaseFirestore.instance
        .collection('artists')
        .where('id_festival', isEqualTo: festivalId.trim())
        .where('stage', isEqualTo: stage)
        .where('date', isEqualTo: date)
        .get();

    final artists = querySnapshot.docs
        .map((doc) => Artist.fromJson({...doc.data(), 'id': doc.id}))
        .toList();

    final withTime = artists.where((a) => a.time != null).toList();
    final withoutTime = artists.where((a) => a.time == null).toList();

    withTime.sort((a, b) {
      int parseTime(String time) {
        final parts = time.split(':');
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);
        if (hour < 6) hour += 24;
        return hour * 60 + minute;
      }

      return parseTime(a.time!) - parseTime(b.time!);
    });

    return [...withTime, ...withoutTime];
  }
}
