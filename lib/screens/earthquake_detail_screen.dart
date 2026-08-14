import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart' hide DistanceCalculator;
import 'package:url_launcher/url_launcher.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/date_formatter.dart';
import '../core/utils/distance_calculator.dart';
import '../models/earthquake_model.dart';
import '../services/location_service.dart';
import '../widgets/magnitude_badge.dart';

/// Pantalla de detalle para un evento sísmico específico con mapa interactivo de epicentro
class EarthquakeDetailScreen extends StatelessWidget {
  final EarthquakeModel earthquake;
  final UserLocationResult? userLocation;

  const EarthquakeDetailScreen({
    super.key,
    required this.earthquake,
    this.userLocation,
  });

  Future<void> _openUsgsWebPage(BuildContext context) async {
    final Uri url = Uri.parse(earthquake.url);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el enlace de USGS.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final magColor = AppTheme.getColorForMagnitude(earthquake.magnitude);
    final intensityLabel = AppTheme.getLabelForMagnitude(earthquake.magnitude);

    final LatLng epicenterPos = LatLng(earthquake.latitude, earthquake.longitude);
    final LatLng? userPos = (userLocation != null)
        ? LatLng(userLocation!.latitude, userLocation!.longitude)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalle de Sismo',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser_rounded),
            tooltip: 'Ver Reporte Oficial USGS',
            onPressed: () => _openUsgsWebPage(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Encabezado de Magnitud e Intensidad
            Container(
              padding: const EdgeInsets.all(20),
              color: magColor.withValues(alpha: 0.12),
              child: Row(
                children: [
                  MagnitudeBadge(
                    magnitude: earthquake.magnitude,
                    size: 70,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          earthquake.cleanPlaceName,
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: magColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                intensityLabel,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            if (earthquake.tsunami > 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Alerta Tsunami',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. Mapa Interactivo de Epicentro y Ubicación GPS
            SizedBox(
              height: 250,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: epicenterPos,
                  initialZoom: 7.5,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.sismojima.app',
                  ),
                  // Línea geodésica entre usuario y epicentro
                  if (userPos != null)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: [userPos, epicenterPos],
                          strokeWidth: 3.0,
                          color: AppTheme.accentColor,
                        ),
                      ],
                    ),
                  MarkerLayer(
                    markers: [
                      // Marcador de Epicentro
                      Marker(
                        point: epicenterPos,
                        width: 50,
                        height: 50,
                        child: Icon(
                          Icons.location_on_rounded,
                          size: 44,
                          color: magColor,
                        ),
                      ),
                      // Marcador de Usuario GPS
                      if (userPos != null)
                        Marker(
                          point: userPos,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.my_location_rounded,
                            size: 30,
                            color: Colors.blueAccent,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // 3. Grid de Datos Técnicos y Métricas
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Parámetros Geofísicos',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),

                  GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    children: [
                      _buildMetricTile(
                        context,
                        icon: Icons.south_rounded,
                        label: 'Profundidad (Hipocentro)',
                        value: '${earthquake.depth.toStringAsFixed(1)} km',
                      ),
                      _buildMetricTile(
                        context,
                        icon: Icons.near_me_rounded,
                        label: 'Distancia a tu GPS',
                        value: earthquake.distanceFromUser != null
                            ? DistanceCalculator.formatDistance(earthquake.distanceFromUser!)
                            : 'N/A',
                      ),
                      _buildMetricTile(
                        context,
                        icon: Icons.place_rounded,
                        label: 'Latitud',
                        value: '${earthquake.latitude.toStringAsFixed(4)}°',
                      ),
                      _buildMetricTile(
                        context,
                        icon: Icons.explore_rounded,
                        label: 'Longitud',
                        value: '${earthquake.longitude.toStringAsFixed(4)}°',
                      ),
                      _buildMetricTile(
                        context,
                        icon: Icons.stars_rounded,
                        label: 'Significancia USGS',
                        value: '${earthquake.significance} / 1000',
                      ),
                      _buildMetricTile(
                        context,
                        icon: Icons.access_time_filled_rounded,
                        label: 'Hora del Evento',
                        value: DateFormatter.formatRelativeTime(earthquake.time),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Fecha Completa
                  Text(
                    'Fecha y Hora Exacta:',
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormatter.formatFullDate(earthquake.time),
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Botón para consultar USGS en la web
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: theme.colorScheme.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.language_rounded),
                      label: Text(
                        'Abrir Ficha Técnica en USGS.gov',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () => _openUsgsWebPage(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
