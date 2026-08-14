import 'dart:async';
import 'package:flutter/material.dart';
import '../core/constants/api_constants.dart';
import '../core/utils/distance_calculator.dart';
import '../models/earthquake_model.dart';
import '../services/alert_preferences_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../services/usgs_api_service.dart';
import '../services/usgs_websocket_service.dart';

/// Criterios de Ordenamiento
enum SortOption {
  timeDescending,
  magnitudeDescending,
  proximity,
}

/// Gestor de Estado Global (Provider) con WebSocket Live (0s Latencia) y Alertas Emergentes
class EarthquakeProvider extends ChangeNotifier {
  final UsgsApiService _usgsApiService;
  final LocationService _locationService;
  final NotificationService _notificationService;
  final AlertPreferencesService _preferencesService;
  final UsgsWebSocketService _webSocketService;

  Timer? _realTimeTimer;

  EarthquakeProvider({
    UsgsApiService? usgsApiService,
    LocationService? locationService,
    NotificationService? notificationService,
    AlertPreferencesService? preferencesService,
    UsgsWebSocketService? webSocketService,
  })  : _usgsApiService = usgsApiService ?? UsgsApiService(),
        _locationService = locationService ?? LocationService(),
        _notificationService = notificationService ?? NotificationService(),
        _preferencesService = preferencesService ?? AlertPreferencesService(),
        _webSocketService = webSocketService ?? UsgsWebSocketService();

  // Estado General
  List<EarthquakeModel> _allEarthquakes = [];
  List<EarthquakeModel> _displayedEarthquakes = [];
  UserLocationResult? _userLocation;
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastRealTimeFetch;

  // Filtros de Vista
  String _selectedPeriod = ApiConstants.periodWeek;
  double _minMagnitude = 0.0;
  double? _maxRadiusKm;
  bool _limitColombiaRegion = true;
  SortOption _sortOption = SortOption.timeDescending;

  // Configuración de Alertas Emergentes de Evacuación
  bool _alertsEnabled = true;
  double _alertMinMagnitude = 3.5;
  double _alertMaxRadiusKm = 300.0;
  int _pollingIntervalSeconds = 15;
  Set<String> _notifiedEarthquakeIds = {};

  // Getters Públicos
  List<EarthquakeModel> get earthquakes => _displayedEarthquakes;
  UserLocationResult? get userLocation => _userLocation;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get lastRealTimeFetch => _lastRealTimeFetch;
  String get selectedPeriod => _selectedPeriod;
  double get minMagnitude => _minMagnitude;
  double? get maxRadiusKm => _maxRadiusKm;
  bool get limitColombiaRegion => _limitColombiaRegion;
  SortOption get sortOption => _sortOption;
  int get totalEventsCount => _allEarthquakes.length;

  // Getters de Alertas Emergentes y WebSocket
  bool get alertsEnabled => _alertsEnabled;
  double get alertMinMagnitude => _alertMinMagnitude;
  double get alertMaxRadiusKm => _alertMaxRadiusKm;
  int get pollingIntervalSeconds => _pollingIntervalSeconds;
  bool get isRealTimeActive => _realTimeTimer != null && _realTimeTimer!.isActive;
  bool get isWebSocketConnected => _webSocketService.isConnected;

  /// Retorna el sismo más cercano a la ubicación GPS
  EarthquakeModel? get nearestEarthquake {
    if (_displayedEarthquakes.isEmpty) return null;
    EarthquakeModel? nearest;
    double minDistance = double.infinity;
    for (var eq in _displayedEarthquakes) {
      if (eq.distanceFromUser != null && eq.distanceFromUser! < minDistance) {
        minDistance = eq.distanceFromUser!;
        nearest = eq;
      }
    }
    return nearest;
  }

  /// Inicializa el estado, notificaciones, WebSocket y sondeo de respaldo
  Future<void> init() async {
    await _loadPreferences();
    await _notificationService.init();
    await fetchEarthquakes(isBackgroundPolling: false);

    // Conectar WebSocket en vivo
    _connectWebSocket();

    // Sondeo de respaldo cada 15 segundos
    _startRealTimePolling();
  }

  /// Conecta el WebSocket para escuchar el stream de sismos en vivo (0s latencia)
  void _connectWebSocket() {
    final lat = _userLocation?.latitude ?? ApiConstants.defaultLat;
    final lon = _userLocation?.longitude ?? ApiConstants.defaultLong;

    _webSocketService.connect(
      onEarthquakeReceived: (newEq) {
        // Al recibir un sismo en tiempo real por el socket
        _onLiveEarthquakeReceived(newEq);
      },
      userLat: lat,
      userLong: lon,
      alertMinMagnitude: _alertMinMagnitude,
      alertMaxRadiusKm: _alertMaxRadiusKm,
    );
  }

  /// Procesa un sismo entrante por el WebSocket en vivo
  void _onLiveEarthquakeReceived(EarthquakeModel newEq) {
    final bool exists = _allEarthquakes.any((eq) => eq.id == newEq.id);
    if (!exists) {
      _allEarthquakes.insert(0, newEq);
      _applyFiltersAndSorting();
      notifyListeners();
    }
  }

  /// Carga la configuración de notificaciones guardada
  Future<void> _loadPreferences() async {
    final prefs = await _preferencesService.loadPreferences();
    _alertsEnabled = prefs['alertsEnabled'] as bool;
    _alertMinMagnitude = prefs['alertMinMagnitude'] as double;
    _alertMaxRadiusKm = prefs['alertMaxRadiusKm'] as double;
    _pollingIntervalSeconds = prefs['pollingIntervalSeconds'] as int;
    _notifiedEarthquakeIds = prefs['notifiedIds'] as Set<String>;
  }

  /// Inicia el temporizador de sondeo periódico de respaldo
  void _startRealTimePolling() {
    _realTimeTimer?.cancel();
    _realTimeTimer = Timer.periodic(
      Duration(seconds: _pollingIntervalSeconds),
      (_) => fetchEarthquakes(isBackgroundPolling: true),
    );
  }

  /// Realiza la consulta a la API de USGS e inspeciona sismos para Alertas Emergentes
  Future<void> fetchEarthquakes({bool isBackgroundPolling = false}) async {
    if (!isBackgroundPolling) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      // 1. Obtener ubicación GPS
      _userLocation = await _locationService.getCurrentUserLocation();

      // 2. Consultar API de USGS
      final fetchedList = await _usgsApiService.fetchEarthquakes(
        period: _selectedPeriod,
        minMagnitude: _minMagnitude,
        limitColombiaRegion: _limitColombiaRegion,
      );

      _allEarthquakes = fetchedList;
      _lastRealTimeFetch = DateTime.now();

      // 3. Calcular distancias relativas
      if (_userLocation != null) {
        for (var eq in _allEarthquakes) {
          eq.distanceFromUser = DistanceCalculator.calculateDistanceKm(
            _userLocation!.latitude,
            _userLocation!.longitude,
            eq.latitude,
            eq.longitude,
          );
        }
      }

      // 4. EVALUAR ALERTAS DE EMERGENCIA EN TIEMPO REAL
      if (_alertsEnabled) {
        _evaluateEmergencyAlerts();
      }

      // 5. Aplicar filtros y ordenamiento a la vista
      _applyFiltersAndSorting();
    } catch (e) {
      if (!isBackgroundPolling) {
        _errorMessage = e.toString();
      }
    } finally {
      if (!isBackgroundPolling) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  /// Evalúa si existen nuevos sismos cercanos que requieran disparar la Alerta Emergente en el teléfono
  void _evaluateEmergencyAlerts() {
    for (var eq in _allEarthquakes) {
      if (_notifiedEarthquakeIds.contains(eq.id)) continue;

      final double distance = eq.distanceFromUser ?? double.infinity;

      if (eq.magnitude >= _alertMinMagnitude && distance <= _alertMaxRadiusKm) {
        _notificationService.showEarthquakeEmergencyAlert(
          earthquake: eq,
          distanceKm: distance,
        );

        _notifiedEarthquakeIds.add(eq.id);
        _preferencesService.addNotifiedId(eq.id);
      }
    }
  }

  /// Aplica los filtros de vista
  void _applyFiltersAndSorting() {
    List<EarthquakeModel> list = List.from(_allEarthquakes);

    if (_minMagnitude > 0.0) {
      list = list.where((eq) => eq.magnitude >= _minMagnitude).toList();
    }

    if (_maxRadiusKm != null && _maxRadiusKm! > 0) {
      list = list
          .where((eq) =>
              eq.distanceFromUser != null &&
              eq.distanceFromUser! <= _maxRadiusKm!)
          .toList();
    }

    switch (_sortOption) {
      case SortOption.timeDescending:
        list.sort((a, b) => b.time.compareTo(a.time));
        break;
      case SortOption.magnitudeDescending:
        list.sort((a, b) => b.magnitude.compareTo(a.magnitude));
        break;
      case SortOption.proximity:
        list.sort((a, b) {
          final distA = a.distanceFromUser ?? double.infinity;
          final distB = b.distanceFromUser ?? double.infinity;
          return distA.compareTo(distB);
        });
        break;
    }

    _displayedEarthquakes = list;
  }

  // --- MÉTODOS DE CONFIGURACIÓN DE ALERTAS DE EMERGENCIA ---

  Future<void> toggleAlertsEnabled(bool value) async {
    _alertsEnabled = value;
    await _preferencesService.setAlertsEnabled(value);
    notifyListeners();
  }

  Future<void> setAlertMinMagnitude(double minMag) async {
    _alertMinMagnitude = minMag;
    await _preferencesService.setAlertMinMagnitude(minMag);
    notifyListeners();
  }

  Future<void> setAlertMaxRadiusKm(double radiusKm) async {
    _alertMaxRadiusKm = radiusKm;
    await _preferencesService.setAlertMaxRadiusKm(radiusKm);
    notifyListeners();
  }

  Future<void> setPollingIntervalSeconds(int intervalSec) async {
    _pollingIntervalSeconds = intervalSec;
    await _preferencesService.setPollingIntervalSeconds(intervalSec);
    _startRealTimePolling();
    notifyListeners();
  }

  Future<void> triggerTestAlert() async {
    await _notificationService.showTestAlert();
  }

  // --- FILTROS REGULARES ---

  Future<void> setPeriod(String period) async {
    if (_selectedPeriod == period) return;
    _selectedPeriod = period;
    await fetchEarthquakes(isBackgroundPolling: false);
  }

  void setMinMagnitude(double minMag) {
    _minMagnitude = minMag;
    _applyFiltersAndSorting();
    notifyListeners();
  }

  void setMaxRadiusKm(double? radiusKm) {
    _maxRadiusKm = radiusKm;
    _applyFiltersAndSorting();
    notifyListeners();
  }

  Future<void> toggleColombiaRegion(bool limitColombia) async {
    if (_limitColombiaRegion == limitColombia) return;
    _limitColombiaRegion = limitColombia;
    await fetchEarthquakes(isBackgroundPolling: false);
  }

  void setSortOption(SortOption option) {
    _sortOption = option;
    _applyFiltersAndSorting();
    notifyListeners();
  }

  Future<void> refresh() async {
    await fetchEarthquakes(isBackgroundPolling: false);
  }

  @override
  void dispose() {
    _realTimeTimer?.cancel();
    _webSocketService.disconnect();
    super.dispose();
  }
}
