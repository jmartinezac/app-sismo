import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/api_constants.dart';
import '../providers/earthquake_provider.dart';
import 'alert_settings_card.dart';

/// Modal para personalizar filtros de búsqueda y configuración de alertas de emergencia
class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EarthquakeProvider>(context);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Indicador de arrastre superior
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtros y Alertas Sísmicas',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    provider.setMinMagnitude(0.0);
                    provider.setMaxRadiusKm(null);
                    provider.setSortOption(SortOption.timeDescending);
                  },
                  child: const Text('Restablecer'),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // SECCIÓN DE ALERTAS EMERGENTES EN TIEMPO REAL (ShakeAlert)
            const AlertSettingsCard(),

            const SizedBox(height: 16),

            // Section 1: Magnitud Mínima en Lista
            Text(
              'Magnitud Mínima en Lista: ${provider.minMagnitude > 0 ? provider.minMagnitude.toStringAsFixed(1) : 'Todas'}',
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            Slider(
              value: provider.minMagnitude,
              min: 0.0,
              max: 6.0,
              divisions: 12,
              label: provider.minMagnitude > 0 ? 'M${provider.minMagnitude}' : 'Todas',
              onChanged: (val) {
                provider.setMinMagnitude(val);
              },
            ),

            const SizedBox(height: 12),

            // Section 2: Radio Geográfico respecto a tu GPS
            Text(
              'Radio Máximo de Lista desde tu GPS',
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('Sin límite'),
                  selected: provider.maxRadiusKm == null,
                  onSelected: (_) => provider.setMaxRadiusKm(null),
                ),
                FilterChip(
                  label: const Text('200 km'),
                  selected: provider.maxRadiusKm == 200,
                  onSelected: (_) => provider.setMaxRadiusKm(200),
                ),
                FilterChip(
                  label: const Text('500 km'),
                  selected: provider.maxRadiusKm == 500,
                  onSelected: (_) => provider.setMaxRadiusKm(500),
                ),
                FilterChip(
                  label: const Text('1.000 km'),
                  selected: provider.maxRadiusKm == 1000,
                  onSelected: (_) => provider.setMaxRadiusKm(1000),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Section 3: Ventana de Tiempo
            Text(
              'Período de Tiempo',
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ApiConstants.periodLabels.entries.map((entry) {
                final isSelected = provider.selectedPeriod == entry.key;
                return ChoiceChip(
                  label: Text(entry.value),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      provider.setPeriod(entry.key);
                    }
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Section 4: Ordenamiento
            Text(
              'Ordenar Lista Por',
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  avatar: const Icon(Icons.schedule, size: 16),
                  label: const Text('Más Recientes'),
                  selected: provider.sortOption == SortOption.timeDescending,
                  onSelected: (_) => provider.setSortOption(SortOption.timeDescending),
                ),
                ChoiceChip(
                  avatar: const Icon(Icons.near_me, size: 16),
                  label: const Text('Más Cercanos a ti'),
                  selected: provider.sortOption == SortOption.proximity,
                  onSelected: (_) => provider.setSortOption(SortOption.proximity),
                ),
                ChoiceChip(
                  avatar: const Icon(Icons.warning, size: 16),
                  label: const Text('Mayor Magnitud'),
                  selected: provider.sortOption == SortOption.magnitudeDescending,
                  onSelected: (_) => provider.setSortOption(SortOption.magnitudeDescending),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Section 5: Delimitación Región Colombia
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Limitar a Región Colombia',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text('Coordenadas Lat -4.2° a 13.5°, Lon -82.0° a -66.8°'),
              value: provider.limitColombiaRegion,
              onChanged: (val) {
                provider.toggleColombiaRegion(val);
              },
            ),

            const SizedBox(height: 20),

            // Botón de Aplicar
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Aplicar y Cerrar',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
