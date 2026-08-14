import 'package:intl/intl.dart';

/// Utilidades de formateo de fechas y horas en idioma español para eventos sísmicos
class DateFormatter {
  /// Retorna la fecha corta con el día de la semana, día del mes y la hora en español (ej: "Mié, 13 Ago • 10:15")
  static String formatDayAndDate(DateTime dateTime) {
    final String formatted = DateFormat('EEE, d MMM • HH:mm', 'es').format(dateTime);
    // Capitalizar primera letra del día de la semana
    return formatted.substring(0, 1).toUpperCase() + formatted.substring(1);
  }

  /// Retorna un texto de tiempo transcurrido o relativo en español
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now().toUtc().subtract(const Duration(hours: 5));
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Hace instantes';
    } else if (difference.inMinutes < 60) {
      final mins = difference.inMinutes;
      return 'Hace $mins ${mins == 1 ? 'minuto' : 'minutos'}';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return 'Hace $hours ${hours == 1 ? 'hora' : 'horas'}';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return 'Hace $days ${days == 1 ? 'día' : 'días'}';
    } else {
      return DateFormat('d MMM yyyy, HH:mm', 'es').format(dateTime);
    }
  }

  /// Retorna la fecha exacta formateada en estándar local (ej: "13 de Agosto, 10:15")
  static String formatFullDate(DateTime dateTime) {
    return DateFormat('d \'de\' MMMM yyyy - HH:mm:ss', 'es').format(dateTime);
  }
}
