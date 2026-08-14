/// Constantes globales para la aplicación SismoJima
/// Incluye los parámetros de conexión a la API REST de la USGS
/// y los límites geográficos (Bounding Box) de la República de Colombia.
class ApiConstants {
  /// Base URL de la API de sismos de USGS (FDSN Web Service)
  static const String usgsBaseUrl =
      'https://earthquake.usgs.gov/fdsnws/event/1/query';

  /// Parámetros geográficos para delimitar la región de Colombia y zonas limítrofes
  /// Latitud Sur: -4.2° (Leticia, Amazonas)
  static const double colombiaMinLat = -4.2;

  /// Latitud Norte: 13.5° (San Andrés / Punta Gallinas, La Guajira)
  static const double colombiaMaxLat = 13.5;

  /// Longitud Oeste: -82.0° (Mar Caribe y Océano Pacífico colombiano)
  static const double colombiaMinLong = -82.0;

  /// Longitud Este: -66.8° (Frontera oriental Guainía / Vichada)
  static const double colombiaMaxLong = -66.8;

  /// Ubicación por defecto en caso de no disponer de GPS (Bogotá, Colombia)
  static const double defaultLat = 4.5709;
  static const double defaultLong = -74.2973;
  static const String defaultLocationName = 'Bogotá, Colombia (Default)';

  /// Períodos de tiempo disponibles para filtro
  static const String periodHour = 'past_hour';
  static const String periodDay = 'past_day';
  static const String periodWeek = 'past_week';
  static const String periodMonth = 'past_month';

  /// Etiquetas legibles de los períodos
  static const Map<String, String> periodLabels = {
    periodHour: 'Última hora',
    periodDay: 'Últimas 24 horas',
    periodWeek: 'Últimos 7 días',
    periodMonth: 'Últimos 30 días',
  };

  /// Magnitudes mínimas predefinidas
  static const List<double> minMagnitudes = [0.0, 2.5, 4.0, 5.0, 6.0];
}
