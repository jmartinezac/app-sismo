import 'package:flutter_test/flutter_test.dart';
import 'package:sismo_jima/core/utils/distance_calculator.dart';
import 'package:sismo_jima/models/earthquake_model.dart';

void main() {
  group('DistanceCalculator Tests', () {
    test('Calcula distancia precisa entre Bogotá y Medellín (~240 km)', () {
      // Bogotá: 4.5709, -74.2973
      // Medellín: 6.2442, -75.5812
      final distance = DistanceCalculator.calculateDistanceKm(
        4.5709,
        -74.2973,
        6.2442,
        -75.5812,
      );

      expect(distance, greaterThan(230));
      expect(distance, lessThan(250));
    });

    test('Formateador de distancia muestra km o metros adecuadamente', () {
      expect(DistanceCalculator.formatDistance(0.5), '500 m');
      expect(DistanceCalculator.formatDistance(5.4), '5.4 km');
      expect(DistanceCalculator.formatDistance(120.8), '121 km');
    });
  });

  group('EarthquakeModel GeoJSON Parser Tests', () {
    test('Parsea correctamente un evento GeoJSON de la USGS', () {
      final sampleGeoJson = {
        'id': 'us7000m9xx',
        'properties': {
          'mag': 4.8,
          'place': '14 km W of Los Santos, Colombia',
          'time': 1691928300000,
          'updated': 1691929000000,
          'url': 'https://earthquake.usgs.gov/earthquakes/eventpage/us7000m9xx',
          'tsunami': 0,
          'sig': 354,
        },
        'geometry': {
          'coordinates': [-73.18, 6.78, 145.2],
        },
      };

      final eq = EarthquakeModel.fromJson(sampleGeoJson);

      expect(eq.id, 'us7000m9xx');
      expect(eq.magnitude, 4.8);
      expect(eq.cleanPlaceName, 'Los Santos, Colombia');
      expect(eq.distanceVector, '14 km W');
      expect(eq.latitude, 6.78);
      expect(eq.longitude, -73.18);
      expect(eq.depth, 145.2);
    });
  });
}
