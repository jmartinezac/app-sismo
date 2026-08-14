import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/distance_calculator.dart';
import '../models/earthquake_model.dart';
import '../services/location_service.dart';

/// Tarjeta de Resumen superior con la Ubicación del Usuario y Alerta Sísmica más Cercana
class LocationHeaderCard extends StatelessWidget {
  final UserLocationResult? userLocation;
  final int totalCount;
  final EarthquakeModel? nearestEarthquake;
  final VoidCallback onTapFilters;

  const LocationHeaderCard({
    super.key,
    required this.userLocation,
    required this.totalCount,
    this.nearestEarthquake,
    required this.onTapFilters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isFallback = userLocation?.isDefaultFallback ?? true;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: theme.brightness == Brightness.dark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFFE0F2FE), const Color(0xFFBAE6FD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila 1: GPS Status Badge + Filtro Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isFallback ? Icons.location_off_rounded : Icons.my_location_rounded,
                    size: 18,
                    color: isFallback ? Colors.amber : AppTheme.accentColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isFallback ? 'GPS: Usando Bogotá (Default)' : 'GPS Activo',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isFallback ? Colors.amber : AppTheme.accentColor,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: onTapFilters,
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                ),
                tooltip: 'Filtros y Opciones',
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Fila 2: Total de sismos en pantalla
          Text(
            '$totalCount sismos detectados en el rango',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Fila 3: Sismo más cercano a la ubicación
          if (nearestEarthquake != null && nearestEarthquake!.distanceFromUser != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(height: 1),
            ),
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 20,
                  color: AppTheme.getColorForMagnitude(nearestEarthquake!.magnitude),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                      children: [
                        const TextSpan(text: 'Más cercano: '),
                        TextSpan(
                          text: '${nearestEarthquake!.cleanPlaceName} ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: '(${DistanceCalculator.formatDistance(nearestEarthquake!.distanceFromUser!)})',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
