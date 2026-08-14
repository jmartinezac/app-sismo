/// Modelo de Datos para representar un Evento Sísmico (GeoJSON Feature) de la USGS API
class EarthquakeModel {
  final String id;
  final double magnitude;
  final String place;
  final DateTime time;
  final DateTime updated;
  final String url;
  final String? detailUrl;
  final int tsunami;
  final int significance;
  final double latitude;
  final double longitude;
  final double depth;

  /// Distancia calculada en tiempo real respecto al GPS del usuario (en Kilómetros)
  double? distanceFromUser;

  EarthquakeModel({
    required this.id,
    required this.magnitude,
    required this.place,
    required this.time,
    required this.updated,
    required this.url,
    this.detailUrl,
    required this.tsunami,
    required this.significance,
    required this.latitude,
    required this.longitude,
    required this.depth,
    this.distanceFromUser,
  });

  /// Constructor Factory para crear una instancia de [EarthquakeModel] a partir del objeto GeoJSON `feature` de USGS.
  factory EarthquakeModel.fromJson(Map<String, dynamic> json) {
    final properties = json['properties'] as Map<String, dynamic>? ?? {};
    final geometry = json['geometry'] as Map<String, dynamic>? ?? {};
    final coordinates = (geometry['coordinates'] as List<dynamic>?) ?? [0.0, 0.0, 0.0];

    // Extraer coordenadas: GeoJSON especifica [Longitud, Latitud, Profundidad]
    final double lon = (coordinates.isNotEmpty) ? (coordinates[0] as num).toDouble() : 0.0;
    final double lat = (coordinates.length > 1) ? (coordinates[1] as num).toDouble() : 0.0;
    final double dep = (coordinates.length > 2) ? (coordinates[2] as num).toDouble() : 0.0;

    return EarthquakeModel(
      id: json['id'] as String? ?? '',
      magnitude: (properties['mag'] as num?)?.toDouble() ?? 0.0,
      place: properties['place'] as String? ?? 'Ubicación desconocida',
      time: DateTime.fromMillisecondsSinceEpoch(
        (properties['time'] as num?)?.toInt() ?? 0,
        isUtc: true,
      ).toUtc().subtract(const Duration(hours: 5)),
      updated: DateTime.fromMillisecondsSinceEpoch(
        (properties['updated'] as num?)?.toInt() ?? 0,
        isUtc: true,
      ).toUtc().subtract(const Duration(hours: 5)),
      url: properties['url'] as String? ?? '',
      detailUrl: properties['detail'] as String?,
      tsunami: (properties['tsunami'] as num?)?.toInt() ?? 0,
      significance: (properties['sig'] as num?)?.toInt() ?? 0,
      longitude: lon,
      latitude: lat,
      depth: dep,
    );
  }

  /// Limpia la descripción del lugar para eliminar prefijos genéricos (ej. "12km ESE of...")
  String get cleanPlaceName {
    if (place.contains(' of ')) {
      final parts = place.split(' of ');
      return parts.length > 1 ? parts[1].trim() : place;
    }
    return place;
  }

  /// Retorna la especificación del vector de distancia respecto a la referencia USGS (ej. "12km ESE")
  String get distanceVector {
    if (place.contains(' of ')) {
      return place.split(' of ')[0].trim();
    }
    return '';
  }
}
