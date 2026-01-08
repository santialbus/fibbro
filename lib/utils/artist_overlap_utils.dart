import '../domain/artists_domain.dart';

class ArtistOverlapUtils {

  static Map<String, List<String>> artistasSolapados(
      List<FestivalArtistDomain> artistas,
      ) {
    final ranges = artistas
        .where((a) => a.startTime.isNotEmpty && a.duration > 0)
        .map(_toRange)
        .toList();

    return _calculateOverlaps(ranges);
  }

  static _ArtistTimeRange _toRange(FestivalArtistDomain artist) {
    final start = _toMinutes(artist.startTime);
    final end = start + artist.duration;

    return _ArtistTimeRange(
      artistId: artist.id,
      start: start,
      end: end,
    );
  }

  static int _toMinutes(String time) {
    final parts = time.split(':');
    var hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    if (hour < 6) hour += 24;

    return hour * 60 + minute;
  }

  static Map<String, List<String>> _calculateOverlaps(
      List<_ArtistTimeRange> ranges,
      ) {
    final overlaps = <String, List<String>>{};

    for (var i = 0; i < ranges.length; i++) {
      for (var j = i + 1; j < ranges.length; j++) {
        final a = ranges[i];
        final b = ranges[j];

        if (_overlaps(a, b)) {
          overlaps.putIfAbsent(a.artistId, () => []).add(b.artistId);
          overlaps.putIfAbsent(b.artistId, () => []).add(a.artistId);
        }
      }
    }
    return overlaps;
  }

  static bool _overlaps(
      _ArtistTimeRange a,
      _ArtistTimeRange b,
      ) {
    return a.start < b.end && b.start < a.end;
  }
}

class _ArtistTimeRange {
  final String artistId;
  final int start;
  final int end;

  const _ArtistTimeRange({
    required this.artistId,
    required this.start,
    required this.end,
  });
}
