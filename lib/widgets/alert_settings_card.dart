import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/earthquake_provider.dart';

/// Tarjeta de Configuración de Alertas Emergentes de Evacuación Sísmica (ShakeAlert Style)
class AlertSettingsCard extends StatelessWidget {
  const AlertSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EarthquakeProvider>(context);
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: provider.alertsEnabled
              ? AppTheme.magSevere.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de la Tarjeta
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: provider.alertsEnabled
                      ? AppTheme.magSevere.withValues(alpha: 0.15)
                      : Colors.grey.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_active_rounded,
                  color: provider.alertsEnabled ? AppTheme.magSevere : Colors.grey,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alertas Emergentes de Evacuación',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Notificaciones flotantes de alta prioridad',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: provider.alertsEnabled,
                activeThumbColor: AppTheme.magSevere,
                onChanged: (val) => provider.toggleAlertsEnabled(val),
              ),
            ],
          ),

          if (provider.alertsEnabled) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Divider(height: 1),
            ),

            // Umbral 1: Magnitud Mínima para Alerta Emergente
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Magnitud mínima de alerta:',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.getColorForMagnitude(provider.alertMinMagnitude)
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'M ≥ ${provider.alertMinMagnitude.toStringAsFixed(1)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.getColorForMagnitude(provider.alertMinMagnitude),
                    ),
                  ),
                ),
              ],
            ),
            Slider(
              value: provider.alertMinMagnitude,
              min: 2.5,
              max: 6.0,
              divisions: 7,
              activeColor: AppTheme.getColorForMagnitude(provider.alertMinMagnitude),
              label: 'M ≥ ${provider.alertMinMagnitude.toStringAsFixed(1)}',
              onChanged: (val) => provider.setAlertMinMagnitude(val),
            ),

            const SizedBox(height: 8),

            // Umbral 2: Radio Máximo de Alerta desde GPS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Radio máximo de distancia GPS:',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${provider.alertMaxRadiusKm.round()} km',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            Slider(
              value: provider.alertMaxRadiusKm,
              min: 50.0,
              max: 1000.0,
              divisions: 19,
              activeColor: theme.colorScheme.primary,
              label: '${provider.alertMaxRadiusKm.round()} km',
              onChanged: (val) => provider.setAlertMaxRadiusKm(val),
            ),

            const SizedBox(height: 8),

            // Frecuencia de Sondeo en Tiempo Real
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Frecuencia de monitoreo:',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                DropdownButton<int>(
                  value: provider.pollingIntervalSeconds,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 15, child: Text('Cada 15 segundos')),
                    DropdownMenuItem(value: 30, child: Text('Cada 30 segundos')),
                    DropdownMenuItem(value: 60, child: Text('Cada 1 minuto')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      provider.setPollingIntervalSeconds(val);
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Botón de Prueba de Alerta Emergente
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.magSevere,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.vibration_rounded),
                label: Text(
                  '🧪 Probar Alerta Emergente en el Teléfono',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  provider.triggerTestAlert();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notificación emergente de prueba enviada al dispositivo.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
