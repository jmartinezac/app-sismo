import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/earthquake_model.dart';

/// Servicio responsable del sistema de Notificaciones Emergentes (Heads-up Popups) de Alerta Sísmica
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// ID del Canal de Emergencia para Android (Alta Prioridad + Banner + Vibración)
  static const String _channelId = 'sismo_emergency_alerts_v1';
  static const String _channelName = 'Alertas de Evacuación Sísmica';
  static const String _channelDesc =
      'Alertas emergentes de máxima prioridad para sismos cercanos detectados en Colombia.';

  /// Inicializa el plugin de notificaciones locales y solicita permisos en Android 13+ e iOS
  Future<void> init() async {
    if (_isInitialized) return;

    // Configuración para Android
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuración para iOS
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Al tocar la notificación se navega al detalle del sismo
      },
    );

    // Solicitar permiso de notificaciones en Android 13+ (API 33+)
    final androidPlugin =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    _isInitialized = true;
  }

  /// Dispara una Alerta Emergente de Evacuación Sísmica (Banner flotante heads-up + Vibración)
  Future<void> showEarthquakeEmergencyAlert({
    required EarthquakeModel earthquake,
    required double distanceKm,
  }) async {
    await init();

    final int notificationId = earthquake.id.hashCode;

    // Configuración del canal de máxima importancia para Android (ShakeAlert Style)
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      ticker: '¡ALERTA SÍSMICA EN TIEMPO REAL!',
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500, 200, 1000]),
      styleInformation: BigTextStyleInformation(
        'Sismo de M${earthquake.magnitude.toStringAsFixed(1)} a solo ${distanceKm.round()} km de ti (${earthquake.cleanPlaceName}).\n\n'
        '⚠️ ¡MANTÉN LA CALMA, EVALÚA TU ENTORNO Y BUSCA REFUGIO SEGURO!',
        contentTitle: '🚨 ¡ALERTA SÍSMICA CERCANA DETECTADA!',
        summaryText: 'Alerta Temprana SismoJima',
      ),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      id: notificationId,
      title: '🚨 ALERTA SÍSMICA: M${earthquake.magnitude.toStringAsFixed(1)} (${distanceKm.round()} km)',
      body: 'Sismo detectado cerca de ti (${earthquake.cleanPlaceName}). ¡Protégete y ubica tu zona de evacuación!',
      notificationDetails: notificationDetails,
      payload: earthquake.id,
    );
  }

  /// Permite al usuario simular y probar cómo se escucha y ve la alerta emergente en su teléfono
  Future<void> showTestAlert() async {
    await init();

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500, 200, 1000]),
      styleInformation: const BigTextStyleInformation(
        'Esta es una prueba del sistema de Alertas Emergentes de SismoJima.\n\n'
        'Cuando se detecte un sismo real cercano a tu ubicación GPS, recibirás una alerta emergente flotante como esta con instrucciones de evacuación.',
        contentTitle: '🧪 PRUEBA DE ALERTA DE EVACUACIÓN SÍSMICA',
        summaryText: 'Prueba de Sistema SismoJima',
      ),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.active,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      id: 99999,
      title: '🧪 PRUEBA: Alerta Sísmica SismoJima',
      body: 'Sistema de notificaciones emergentes en tiempo real funcionando correctamente.',
      notificationDetails: notificationDetails,
    );
  }
}
