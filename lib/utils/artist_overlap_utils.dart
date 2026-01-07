import '../domain/artists_domain.dart';

class ArtistOverlapUtils {
  static Map<String, List<String>> artistasSolapados(
    List<FestivalArtistDomain> artistas,
  ) {
    Map<String, List<String>> solapamientos = {};

    int tiempoEnMinutos(String time) {
      final parts = time.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      if (hour < 6) hour += 24;
      return hour * 60 + minute;
    }

    List<Map<String, dynamic>> rangos =
        artistas.map((artist) {
          int inicio =
              // ignore: unnecessary_null_comparison
              artist.startTime != null ? tiempoEnMinutos(artist.startTime) : 0;
          int duracion = artist.duration;
          int fin = inicio + duracion;
          return {'id': artist.id, 'inicio': inicio, 'fin': fin};
        }).toList();

    for (int i = 0; i < rangos.length; i++) {
      for (int j = i + 1; j < rangos.length; j++) {
        final a = rangos[i];
        final b = rangos[j];

        bool seSolapan = (a['inicio'] < b['fin']) && (b['inicio'] < a['fin']);

        if (seSolapan) {
          solapamientos.putIfAbsent(a['id'], () => []);
          solapamientos.putIfAbsent(b['id'], () => []);
          solapamientos[a['id']]!.add(b['id']);
          solapamientos[b['id']]!.add(a['id']);
        }
      }
    }

    return solapamientos;
  }
}
