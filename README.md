# 🌋 SismoJima - Sismología para Colombia

SismoJima es una aplicación móvil desarrollada con **Flutter** para **Android** e **iOS**, diseñada para consultar alertas y eventos sísmicos en la región de Colombia y zonas aledañas consumiendo los datos oficiales de la **USGS (United States Geological Survey)**.

## 🚀 Características Principales

- 🇨🇴 **Delimitación Geográfica Regional**: Filtro optimizado para el Bounding Box de Colombia (Lat -4.2° a 13.5°, Lon -82.0° a -66.8°).
- 📍 **Cálculo de Distancia GPS Real**: Mide la distancia geodésica exacta en kilómetros desde la posición actual del usuario hasta el epicentro del sismo utilizando la fórmula de Haversine.
- 🎨 **Interfaz Moderna e Intuitiva**: Insignias cromáticas dinámicas según la severidad del sismo (Leve, Moderado, Fuerte, Mayor, Desastroso) con soporte para Modo Oscuro y Claro.
- 🗺️ **Mapa de Epicentro Interactivo**: Visualiza la ubicación del epicentro y la trayectoria en línea recta hacia tu GPS con `flutter_map` y OpenStreetMap.
- ⚡ **Filtros Avanzados**: Permite filtrar por magnitud mínima, radio en Km respecto a tu ubicación, período de tiempo y ordenamiento por cercanía o severidad.
- 📱 **Ligera y de Bajo Consumo**: Arquitectura optimizada con Provider (ChangeNotifier) y peticiones REST asíncronas.

## 🛠️ Tecnologías Utilizadas

- **Framework**: Flutter 3.11.0 / Dart 3.11.0
- **Gestión de Estado**: `provider`
- **Peticiones HTTP**: `http` (USGS REST FDSN API)
- **Geolocalización**: `geolocator`
- **Mapeo Interactivo**: `flutter_map` & `latlong2`
- **Formateo de Fechas**: `intl`
- **Tipografía**: `google_fonts` (Outfit / Inter)

## 📄 Documentación Técnica

Toda la arquitectura, guía de métodos, fórmulas matemáticas y parámetros geográficos se encuentran detallados en [DOCUMENTATION.md](file:///c:/SismoJima/DOCUMENTATION.md).

## 🚀 Cómo Ejecutar

```bash
# Instalar dependencias
flutter pub get

# Probar compilación y análisis
flutter analyze
flutter test

# Ejecutar la aplicación
flutter run
```

````
flutter pub get
flutter analyze
flutter build apk --release
``````


Android AAB

````
flutter build appbundle

```
