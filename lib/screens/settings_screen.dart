import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/api_constants.dart';
import '../providers/earthquake_provider.dart';
import '../widgets/alert_settings_card.dart';

/// Pantalla de Configuración, Alertas Emergentes e Información de SismoJima
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<EarthquakeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Acerca de y Configuración',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner de la Aplicación
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.sensors_rounded,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'SismoJima',
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Monitoreo Sísmico en Tiempo Real y Alertas de Evacuación',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Chip(
                  label: Text('Versión 1.1.0 (Alertas Emergentes ShakeAlert)',
                      style: GoogleFonts.outfit(fontSize: 11)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // PANEL DE ALERTAS DE EMERGENCIA DE EVACUACIÓN
          const AlertSettingsCard(),

          const SizedBox(height: 20),

          // Parámetros Geográficos de Colombia
          Text(
            'Límites Geográficos (Bounding Box Colombia)',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  _buildConfigRow('Latitud Mínima (Sur)', '${ApiConstants.colombiaMinLat}° (Amazonas)'),
                  const Divider(),
                  _buildConfigRow('Latitud Máxima (Norte)', '${ApiConstants.colombiaMaxLat}° (La Guajira)'),
                  const Divider(),
                  _buildConfigRow('Longitud Mínima (Oeste)', '${ApiConstants.colombiaMinLong}° (Pacífico)'),
                  const Divider(),
                  _buildConfigRow('Longitud Máxima (Este)', '${ApiConstants.colombiaMaxLong}° (Vichada)'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Estado del Sensor GPS
          Text(
            'Estado del Sensor GPS',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Icon(
                provider.userLocation?.isDefaultFallback ?? true
                    ? Icons.location_off
                    : Icons.gps_fixed,
                color: provider.userLocation?.isDefaultFallback ?? true
                    ? Colors.amber
                    : Colors.green,
              ),
              title: Text(
                provider.userLocation?.isDefaultFallback ?? true
                    ? 'GPS Inactivo / Bogotá Fallback'
                    : 'GPS Conectado con Precisión',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                provider.userLocation?.displayName ?? 'Sin coordenadas',
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Fuente de Datos
          Text(
            'Fuente Oficial de Datos',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'United States Geological Survey (USGS)',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Los datos en tiempo real son obtenidos a través del servicio FDSN Web Service en formato GeoJSON de libre consulta mundial.',
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
