import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/date_formatter.dart';
import '../core/utils/distance_calculator.dart';
import '../models/earthquake_model.dart';
import 'magnitude_badge.dart';

/// Tarjeta limpia e intuitiva para mostrar un evento sísmico en la lista con fecha, día y hora
class EarthquakeCard extends StatelessWidget {
  final EarthquakeModel earthquake;
  final VoidCallback onTap;

  const EarthquakeCard({
    super.key,
    required this.earthquake,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final magColor = AppTheme.getColorForMagnitude(earthquake.magnitude);
    final intensityLabel = AppTheme.getLabelForMagnitude(earthquake.magnitude);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: magColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Insignia de Magnitud
                MagnitudeBadge(
                  magnitude: earthquake.magnitude,
                  size: 52,
                ),
                const SizedBox(width: 14),

                // Información Principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Encabezado: Ubicación + Etiqueta de Severidad
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              earthquake.cleanPlaceName,
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: magColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              intensityLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: magColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // FECHA Y DÍA DEL SISMO + TIEMPO RELATIVO
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 13,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormatter.formatDayAndDate(earthquake.time),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '(${DateFormatter.formatRelativeTime(earthquake.time)})',
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Distancia respecto al usuario y alerta tsunami
                      Row(
                        children: [
                          if (earthquake.distanceFromUser != null) ...[
                            Icon(
                              Icons.near_me_outlined,
                              size: 14,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'A ${DistanceCalculator.formatDistance(earthquake.distanceFromUser!)} de ti',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                          if (earthquake.tsunami > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.waves,
                                      size: 12, color: Colors.blue),
                                  SizedBox(width: 2),
                                  Text(
                                    'Tsunami',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ]
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Pie: Vector USGS y Profundidad Hipocentral
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              earthquake.distanceVector.isNotEmpty
                                  ? earthquake.distanceVector
                                  : 'USGS Event',
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.textTheme.bodySmall?.color,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.south_rounded,
                                size: 13,
                                color: theme.textTheme.bodySmall?.color,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'Prof: ${earthquake.depth.toStringAsFixed(1)} km',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.textTheme.bodySmall?.color,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
