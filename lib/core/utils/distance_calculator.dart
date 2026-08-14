import 'dart:math' as math;

/// Calculadora geodésica de distancias utilizando la Fórmula de Haversine
/// Permite calcular la distancia ortodrómica entre dos puntos en la superficie de la Tierra.
class DistanceCalculator {
  /// Radio medio de la Tierra en kilómetros (IUGG value)
  static const double _earthRadiusKm = 6371.0;

  /// Convierte grados a radianes
  static double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180.0;
  }

  /// Calcula la distancia en kilómetros entre dos coordenadas (Latitud, Longitud)
  ///
  /// [lat1], [lon1]: Coordenadas del punto A (ej. Ubicación GPS del usuario)
  /// [lat2], [lon2]: Coordenadas del punto B (ej. Epicentro del sismo)
  /// Retorna la distancia en Kilómetros formateada como `double`.
  static double calculateDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double radLat1 = _degreesToRadians(lat1);
    final double radLat2 = _degreesToRadians(lat2);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(dLon / 2) *
            math.sin(dLon / 2) *
            math.cos(radLat1) *
            math.cos(radLat2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return _earthRadiusKm * c;
  }

  /// Retorna un texto formateado intuitivo para presentar distancias (ej. "45 km", "1.200 km")
  static String formatDistance(double distanceKm) {
    if (distanceKm < 1.0) {
      return '${(distanceKm * 1000).round()} m';
    } else if (distanceKm < 10.0) {
      return '${distanceKm.toStringAsFixed(1)} km';
    } else {
      return '${distanceKm.round()} km';
    }
  }
}
