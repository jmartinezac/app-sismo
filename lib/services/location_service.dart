import 'package:geolocator/geolocator.dart';
import '../core/constants/api_constants.dart';

/// Resultado del servicio de localización
class UserLocationResult {
  final double latitude;
  final double longitude;
  final bool isDefaultFallback;
  final String? permissionStatusMessage;

  UserLocationResult({
    required this.latitude,
    required this.longitude,
    this.isDefaultFallback = false,
    this.permissionStatusMessage,
  });

  String get displayName {
    if (isDefaultFallback) {
      return ApiConstants.defaultLocationName;
    }
    return '${latitude.toStringAsFixed(3)}°, ${longitude.toStringAsFixed(3)}°';
  }
}

/// Servicio encargado del acceso a sensores GPS del dispositivo y permisos del sistema
class LocationService {
  /// Solicita permisos y obtiene las coordenadas GPS actuales del usuario.
  /// Si los servicios están desactivados o los permisos denegados, retorna la ubicación por defecto (Bogotá).
  Future<UserLocationResult> getCurrentUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si el servicio de localización está encendido en el dispositivo
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return UserLocationResult(
        latitude: ApiConstants.defaultLat,
        longitude: ApiConstants.defaultLong,
        isDefaultFallback: true,
        permissionStatusMessage: 'Los servicios de GPS están desactivados en el dispositivo.',
      );
    }

    // Verificar estado de permisos
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return UserLocationResult(
          latitude: ApiConstants.defaultLat,
          longitude: ApiConstants.defaultLong,
          isDefaultFallback: true,
          permissionStatusMessage: 'Permiso de localización denegado por el usuario.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return UserLocationResult(
        latitude: ApiConstants.defaultLat,
        longitude: ApiConstants.defaultLong,
        isDefaultFallback: true,
        permissionStatusMessage:
            'Los permisos de localización están permanentemente denegados en la configuración.',
      );
    }

    // Obtener la posición actual
    try {
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );

      return UserLocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        isDefaultFallback: false,
      );
    } catch (e) {
      // En caso de timeout o falla de GPS, retornar fallback de Bogotá
      return UserLocationResult(
        latitude: ApiConstants.defaultLat,
        longitude: ApiConstants.defaultLong,
        isDefaultFallback: true,
        permissionStatusMessage: 'No se pudo obtener la señal GPS a tiempo.',
      );
    }
  }
}
