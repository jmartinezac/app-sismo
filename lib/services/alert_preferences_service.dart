import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para guardar y recuperar la configuración de Alertas Emergentes en el teléfono
class AlertPreferencesService {
  static const String _keyAlertsEnabled = 'alerts_enabled';
  static const String _keyAlertMinMagnitude = 'alert_min_magnitude';
  static const String _keyAlertMaxRadiusKm = 'alert_max_radius_km';
  static const String _keyPollingIntervalSeconds = 'polling_interval_seconds';
  static const String _keyNotifiedIds = 'notified_earthquake_ids';

  /// Obtiene las preferencias almacenadas
  Future<Map<String, dynamic>> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'alertsEnabled': prefs.getBool(_keyAlertsEnabled) ?? true,
      'alertMinMagnitude': prefs.getDouble(_keyAlertMinMagnitude) ?? 3.5,
      'alertMaxRadiusKm': prefs.getDouble(_keyAlertMaxRadiusKm) ?? 300.0,
      'pollingIntervalSeconds': prefs.getInt(_keyPollingIntervalSeconds) ?? 15,
      'notifiedIds': (prefs.getStringList(_keyNotifiedIds) ?? []).toSet(),
    };
  }

  /// Guarda el estado de activación de alertas
  Future<void> setAlertsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAlertsEnabled, value);
  }

  /// Guarda el umbral de magnitud mínima para notificar
  Future<void> setAlertMinMagnitude(double minMag) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyAlertMinMagnitude, minMag);
  }

  /// Guarda el radio máximo en Km para notificar sismos cercanos
  Future<void> setAlertMaxRadiusKm(double radiusKm) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyAlertMaxRadiusKm, radiusKm);
  }

  /// Guarda el intervalo de sondeo en segundos
  Future<void> setPollingIntervalSeconds(int intervalSec) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyPollingIntervalSeconds, intervalSec);
  }

  /// Agrega un ID de sismo al registro para no notificarlo más de una vez
  Future<void> addNotifiedId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyNotifiedIds) ?? [];
    if (!list.contains(id)) {
      list.add(id);
      // Conservar solo los últimos 200 sismos notificados para no saturar memoria
      if (list.length > 200) {
        list.removeAt(0);
      }
      await prefs.setStringList(_keyNotifiedIds, list);
    }
  }
}
