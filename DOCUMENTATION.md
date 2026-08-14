# Documentación Técnica y Arquitectura - SismoJima

## 1. Visión General del Proyecto

**SismoJima** es una aplicación móvil desarrollada en **Flutter** (para plataformas Android e iOS) diseñada para la consulta, alerta y filtrado en tiempo real de eventos sísmicos en la República de Colombia y sus zonas fronterizas, consumiendo los servicios Web REST GeoJSON de la **USGS (United States Geological Survey)**.

La aplicación cuenta con un **Sistema de Alertas Emergentes Tempranas (ShakeAlert Style)** que ejecuta consultas periódicas en tiempo real y emite **notificaciones de alta prioridad (banner flotante heads-up, sonido y patrones de vibración de evacuación)** cuando se detecta un sismo cercano que supera los umbrales de magnitud y distancia geodésica configurados por el usuario.

---

## 2. Arquitectura del Sistema de Alertas y Tiempo Real

Se implementó el patrón de **Clean Architecture orientado a Funcionalidades (Feature-First Architecture)** apoyado en **Provider (ChangeNotifier)**, `flutter_local_notifications` y `shared_preferences`.

```text
lib/
├── core/
│   ├── constants/
│   │   └── api_constants.dart       # Parámetros USGS y Bounding Box de Colombia
│   ├── theme/
│   │   └── app_theme.dart           # Sistema de diseño, paleta de severidad y modo oscuro
│   └── utils/
│       ├── distance_calculator.dart # Cálculo geodésico Haversine (Km)
│       └── date_formatter.dart      # Formateador de tiempo relativo en español
├── models/
│   └── earthquake_model.dart        # Modelo de datos GeoJSON con parsing seguro
├── services/
│   ├── notification_service.dart   # Canal de notificaciones de máxima prioridad (Heads-up popups)
│   ├── alert_preferences_service.dart # Persistencia de umbrales con SharedPreferences
│   ├── usgs_api_service.dart        # Cliente HTTP REST para consumo USGS
│   └── location_service.dart        # Gestión de permisos GPS y geolocalización
├── providers/
│   └── earthquake_provider.dart     # Gestor de estado con sondeo periódico en tiempo real
├── widgets/
│   ├── real_time_status_badge.dart  # Badge visual animado de monitoreo activo
│   ├── alert_settings_card.dart     # Panel de configuración de alertas y botón de prueba
│   ├── magnitude_badge.dart        # Insignia de color según la magnitud
│   ├── earthquake_card.dart         # Tarjeta de sismo con métricas relativas
│   ├── location_header_card.dart    # Encabezado con estado GPS y alerta más cercana
│   └── filter_bottom_sheet.dart     # Modal interactivo de filtros de usuario
└── screens/
    ├── home_screen.dart             # Dashboard principal con badge de tiempo real
    ├── earthquake_detail_screen.dart# Vista detallada con mapa de epicentro y enlace a USGS
    └── settings_screen.dart         # Ajustes, configuración de emergencias y parámetros
```

---

## 3. Documentación de Métodos y Módulos

### 3.1 Servicio de Notificaciones Emergentes (`NotificationService`)
- **`init()`**: Configura el canal de alta importancia en Android (`sismo_emergency_alerts_v1`) y solicita permisos emergentes en Android 13+ e iOS.
- **`showEarthquakeEmergencyAlert({required EarthquakeModel earthquake, required double distanceKm})`**:
  - Emite un popup flotante en pantalla (*heads-up notification*) con vibración de evacuación `[0, 500, 200, 500, 200, 1000]`.
  - Muestra la orden de evacuación: `"🚨 ALERTA SÍSMICA: M5.2 a 45 km. ¡Protégete y ubica tu zona de evacuación!"`.
- **`showTestAlert()`**: Permite al usuario presionar el botón **"🧪 Probar Alerta Emergente en el Teléfono"** para verificar cómo se escuchará y verá la alerta en su pantalla sin esperar un sismo real.

### 3.2 Sondeo en Tiempo Real (`EarthquakeProvider`)
- **`_startRealTimePolling()`**: Inicia un `Timer.periodic` de sondeo en segundo plano (configurable a 15s, 30s o 60s).
- **`_evaluateEmergencyAlerts()`**:
  Compara cada sismo entrante contra los umbrales del usuario:
  `si (sismo.magnitude >= alertMinMagnitude && distance <= alertMaxRadiusKm && !yaNotificado)`
  -> Llama automáticamente a `showEarthquakeEmergencyAlert(...)` y guarda el ID en `shared_preferences` para evitar alertas duplicadas.

---

## 4. Guía de Ejecución y Pruebas

```bash
# 1. Obtener dependencias
flutter pub get

# 2. Ejecutar análisis estático (0 advertencias/errores)
flutter analyze

# 3. Ejecutar pruebas unitarias
flutter test

# 4. Compilar APK de depuración para Android
flutter build apk --debug
```
