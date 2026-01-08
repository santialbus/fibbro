class DateUtilsHelper {

  /// Convierte cualquier formato conocido a DateTime
  static DateTime parseToDateTime(String raw) {
    final cleaned = raw.replaceAll('/', '-');

    // dd-MM-yyyy → yyyy-MM-dd
    if (RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(cleaned)) {
      final parts = cleaned.split('-');
      return DateTime.parse(
        '${parts[2]}-${parts[1]}-${parts[0]}',
      );
    }

    // yyyy-MM-dd
    return DateTime.parse(cleaned);
  }

  /// Devuelve siempre yyyy-MM-dd (para Firestore / lógica)
  static String normalizeToIso(String raw) {
    return parseToDateTime(raw).toIso8601String().split('T').first;
  }

  /// SOLO UI
  static String formatFullDate(String rawDate) {
    final date = parseToDateTime(rawDate);

    const days = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];

    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];

    return '${days[date.weekday - 1]}, ${date.day} de ${months[date.month - 1]}';
  }


  static String normalizeDate(String date) {
    final parts = date.split('/');
    if (parts.length == 3) {
      final day = parts[0].padLeft(2, '0');
      final month = parts[1].padLeft(2, '0');
      final year = parts[2];
      return '$year-$month-$day';
    }
    return date;
  }

}
