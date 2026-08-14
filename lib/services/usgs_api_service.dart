import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import '../models/earthquake_model.dart';

/// Excepción personalizada para errores del servicio USGS
class UsgsApiException implements Exception {
  final String message;
  final int? statusCode;

  UsgsApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'UsgsApiException: $message ${statusCode != null ? '(Status: $statusCode)' : ''}';
}

/// Servicio de Cliente HTTP para consultar la API REST de la USGS (United States Geological Survey)
class UsgsApiService {
  final http.Client _client;

  UsgsApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Realiza una consulta de eventos sísmicos delimitados por la región de Colombia y parámetros de filtro.
  ///
  /// [period]: Período de consulta ('past_hour', 'past_day', 'past_week', 'past_month')
  /// [minMagnitude]: Magnitud mínima del sismo (ej. 0.0, 2.5, 4.5)
  /// [limitColombiaRegion]: Si es `true`, aplica la delimitación geográfica de Colombia.
  Future<List<EarthquakeModel>> fetchEarthquakes({
    String period = ApiConstants.periodWeek,
    double minMagnitude = 0.0,
    bool limitColombiaRegion = true,
  }) async {
    try {
      final DateTime now = DateTime.now().toUtc();
      late DateTime starttime;

      switch (period) {
        case ApiConstants.periodHour:
          starttime = now.subtract(const Duration(hours: 1));
          break;
        case ApiConstants.periodDay:
          starttime = now.subtract(const Duration(days: 1));
          break;
        case ApiConstants.periodMonth:
          starttime = now.subtract(const Duration(days: 30));
          break;
        case ApiConstants.periodWeek:
        default:
          starttime = now.subtract(const Duration(days: 7));
          break;
      }

      final Map<String, String> queryParams = {
        'format': 'geojson',
        'starttime': starttime.toIso8601String(),
        'minmagnitude': minMagnitude.toString(),
        'orderby': 'time',
      };

      if (limitColombiaRegion) {
        queryParams['minlatitude'] = ApiConstants.colombiaMinLat.toString();
        queryParams['maxlatitude'] = ApiConstants.colombiaMaxLat.toString();
        queryParams['minlongitude'] = ApiConstants.colombiaMinLong.toString();
        queryParams['maxlongitude'] = ApiConstants.colombiaMaxLong.toString();
      }

      final Uri url = Uri.parse(ApiConstants.usgsBaseUrl).replace(
        queryParameters: queryParams,
      );

      final response = await _client.get(url).timeout(
        const Duration(seconds: 12),
        onTimeout: () {
          throw UsgsApiException('Tiempo de espera agotado al conectar con USGS.');
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> features = data['features'] as List<dynamic>? ?? [];

        return features
            .map((item) => EarthquakeModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw UsgsApiException(
          'Error al obtener datos de la API USGS',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is UsgsApiException) rethrow;
      throw UsgsApiException(
        'No hay conexión a Internet o el servidor de sismología no responde.',
      );
    }
  }
}
