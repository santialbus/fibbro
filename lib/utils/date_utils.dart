// lib/utils/date_utils.dart

class DateUtilsHelper {

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
  
  static String formatFullDate(String rawDate) {
    final isoDate = normalizeDate(rawDate);
    final date = DateTime.parse(isoDate);

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

    final dayName = days[date.weekday - 1];
    final day = date.day;
    final monthName = months[date.month - 1];

    return '$dayName, $day de $monthName';
  }

  static String normalizeDateNew(String date) {
    // Si formato dd/MM/yyyy o dd-MM-yyyy, lo invierte a yyyy-MM-dd
    if (RegExp(r'^\d{2}[-/]\d{2}[-/]\d{4}$').hasMatch(date)) {
      final parts = date.split(RegExp(r'[-/]'));
      return '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
    }
    // Reemplaza / por - si ya es yyyy/MM/dd o yyyy-MM-dd
    return date.replaceAll('/', '-');
  }
}
