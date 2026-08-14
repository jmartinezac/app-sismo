import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../core/constants/api_constants.dart';
import '../core/utils/distance_calculator.dart';
import '../models/earthquake_model.dart';
import '../services/notification_service.dart';

/// Callback cuando se recibe un sismo relevante en tiempo cero por WebSocket
typedef OnLiveEarthquakeCallback = void Function(EarthquakeModel earthquake);

/// Servicio de conexión WebSocket en vivo para transmisión de eventos sísmicos en latencia cero (0s)
class UsgsWebSocketService {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  bool _isConnected = false;
  bool _isConnecting = false;
  Timer? _reconnectTimer;

  OnLiveEarthquakeCallback? onLiveEarthquake;

  /// Endpoint de WebSocket de eventos en vivo de USGS
  static const String _wsUrl = 'wss://earthquake.usgs.gov/ws/websockets/';

  bool get isConnected => _isConnected;

  /// Inicia la conexión WebSocket en vivo
  Future<void> connect({
    required OnLiveEarthquakeCallback onEarthquakeReceived,
    required double userLat,
    required double userLong,
    required double alertMinMagnitude,
    required double alertMaxRadiusKm,
  }) async {
    onLiveEarthquake = onEarthquakeReceived;

    if (_isConnected || _isConnecting) return;
    _isConnecting = true;

    try {
      final Uri uri = Uri.parse(_wsUrl);
      _channel = WebSocketChannel.connect(uri);

      _isConnected = true;
      _isConnecting = false;

      debugPrint('⚡ [WebSocket] Conexión WebSocket establecida con USGS Live Stream.');

      _subscription = _channel!.stream.listen(
        (data) {
          _handleIncomingData(
            data,
            userLat: userLat,
            userLong: userLong,
            alertMinMagnitude: alertMinMagnitude,
            alertMaxRadiusKm: alertMaxRadiusKm,
          );
        },
        onError: (error) {
          debugPrint('❌ [WebSocket] Error de conexión: $error');
          _handleDisconnect(
            userLat: userLat,
            userLong: userLong,
            alertMinMagnitude: alertMinMagnitude,
            alertMaxRadiusKm: alertMaxRadiusKm,
          );
        },
        onDone: () {
          debugPrint('🔌 [WebSocket] Conexión cerrada por el servidor.');
          _handleDisconnect(
            userLat: userLat,
            userLong: userLong,
            alertMinMagnitude: alertMinMagnitude,
            alertMaxRadiusKm: alertMaxRadiusKm,
          );
        },
      );
    } catch (e) {
      _isConnected = false;
      _isConnecting = false;
      debugPrint('⚠️ [WebSocket] No se pudo conectar a WebSocket Live. Reintentando...');
      _scheduleReconnect(
        userLat: userLat,
        userLong: userLong,
        alertMinMagnitude: alertMinMagnitude,
        alertMaxRadiusKm: alertMaxRadiusKm,
      );
    }
  }

  /// Procesa los mensajes recibidos por el WebSocket en latencia cero
  void _handleIncomingData(
    dynamic data, {
    required double userLat,
    required double userLong,
    required double alertMinMagnitude,
    required double alertMaxRadiusKm,
  }) {
    try {
      final Map<String, dynamic> json = jsonDecode(data.toString());

      // Verificar si el JSON corresponde a un evento sísmico (GeoJSON Feature)
      if (json.containsKey('properties') && json.containsKey('geometry')) {
        final eq = EarthquakeModel.fromJson(json);

        // Verificar si se encuentra dentro del Bounding Box de Colombia
        final bool isColombia = eq.latitude >= ApiConstants.colombiaMinLat &&
            eq.latitude <= ApiConstants.colombiaMaxLat &&
            eq.longitude >= ApiConstants.colombiaMinLong &&
            eq.longitude <= ApiConstants.colombiaMaxLong;

        if (isColombia) {
          eq.distanceFromUser = DistanceCalculator.calculateDistanceKm(
            userLat,
            userLong,
            eq.latitude,
            eq.longitude,
          );

          onLiveEarthquake?.call(eq);

          // Disparar Alerta Emergente de Evacuación si supera los umbrales del usuario
          if (eq.magnitude >= alertMinMagnitude &&
              eq.distanceFromUser! <= alertMaxRadiusKm) {
            NotificationService().showEarthquakeEmergencyAlert(
              earthquake: eq,
              distanceKm: eq.distanceFromUser!,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ [WebSocket] Error al procesar mensaje de stream: $e');
    }
  }

  /// Maneja la desconexión y programa reconexión automática
  void _handleDisconnect({
    required double userLat,
    required double userLong,
    required double alertMinMagnitude,
    required double alertMaxRadiusKm,
  }) {
    _isConnected = false;
    _isConnecting = false;
    _subscription?.cancel();
    _scheduleReconnect(
      userLat: userLat,
      userLong: userLong,
      alertMinMagnitude: alertMinMagnitude,
      alertMaxRadiusKm: alertMaxRadiusKm,
    );
  }

  /// Programa intento de reconexión cada 10 segundos
  void _scheduleReconnect({
    required double userLat,
    required double userLong,
    required double alertMinMagnitude,
    required double alertMaxRadiusKm,
  }) {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 10), () {
      connect(
        onEarthquakeReceived: onLiveEarthquake ?? (_) {},
        userLat: userLat,
        userLong: userLong,
        alertMinMagnitude: alertMinMagnitude,
        alertMaxRadiusKm: alertMaxRadiusKm,
      );
    });
  }

  /// Cierra la conexión WebSocket activamente
  void disconnect() {
    _reconnectTimer?.cancel();
    _subscription?.cancel();
    _channel?.sink.close();
    _isConnected = false;
    _isConnecting = false;
  }
}
