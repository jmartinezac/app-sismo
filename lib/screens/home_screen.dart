import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/api_constants.dart';
import '../core/theme/app_theme.dart';
import '../providers/earthquake_provider.dart';
import '../widgets/earthquake_card.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/location_header_card.dart';
import '../widgets/real_time_status_badge.dart';
import 'earthquake_detail_screen.dart';
import 'settings_screen.dart';

/// Pantalla Principal (Dashboard) de SismoJima con Monitoreo en Tiempo Real
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Iniciar carga y temporizador en tiempo real
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EarthquakeProvider>(context, listen: false).init();
    });
  }

  void _openFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const FilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<EarthquakeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.sensors_rounded, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Sismos',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(width: 10),
            const RealTimeStatusBadge(),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refrescar Datos',
            onPressed: provider.isLoading ? null : () => provider.refresh(),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Ajustes e Información',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (ctx) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.refresh(),
        child: Column(
          children: [
            // 1. Barra de Chips para Filtros Rápidos
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  ChoiceChip(
                    avatar: const Icon(Icons.map_rounded, size: 16),
                    label: Text(
                      provider.limitColombiaRegion ? 'Colombia' : 'Global',
                    ),
                    selected: provider.limitColombiaRegion,
                    onSelected: (val) => provider.toggleColombiaRegion(true),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('3.0+'),
                    selected: provider.minMagnitude == 3.0,
                    onSelected: (selected) {
                      provider.setMinMagnitude(selected ? 3.0 : 0.0);
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('4.5+'),
                    selected: provider.minMagnitude == 4.5,
                    onSelected: (selected) {
                      provider.setMinMagnitude(selected ? 4.5 : 0.0);
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    avatar: const Icon(Icons.near_me_rounded, size: 16),
                    label: const Text('Más Cercanos'),
                    selected: provider.sortOption == SortOption.proximity,
                    onSelected: (_) => provider.setSortOption(
                      provider.sortOption == SortOption.proximity
                          ? SortOption.timeDescending
                          : SortOption.proximity,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    avatar: Icon(
                      provider.alertsEnabled
                          ? Icons.notifications_active_rounded
                          : Icons.notifications_off_rounded,
                      size: 16,
                      color: provider.alertsEnabled
                          ? AppTheme.magSevere
                          : Colors.grey,
                    ),
                    label: Text(
                      provider.alertsEnabled ? 'Alertas ON' : 'Alertas OFF',
                    ),
                    selected: provider.alertsEnabled,
                    onSelected: (_) => _openFilters(context),
                  ),
                ],
              ),
            ),

            // 2. Tarjeta de Ubicación del Usuario y Resumen de Estado
            LocationHeaderCard(
              userLocation: provider.userLocation,
              totalCount: provider.earthquakes.length,
              nearestEarthquake: provider.nearestEarthquake,
              onTapFilters: () => _openFilters(context),
            ),

            // 3. Contenido Principal: Indicador de Carga / Error / Lista
            Expanded(child: _buildContent(context, provider)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openFilters(context),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.notifications_active_rounded),
        label: Text(
          'Filtros y Alertas',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, EarthquakeProvider provider) {
    final theme = Theme.of(context);

    if (provider.isLoading && provider.earthquakes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Consultando USGS para Colombia...',
              style: GoogleFonts.outfit(fontSize: 15),
            ),
          ],
        ),
      );
    }

    if (provider.errorMessage != null && provider.earthquakes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 64,
                color: AppTheme.magSevere,
              ),
              const SizedBox(height: 16),
              Text(
                'Error de Conexión',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _cleanErrorMessage(provider.errorMessage),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => provider.refresh(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar Conexión'),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.earthquakes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 64,
                color: Colors.grey.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No se registraron sismos',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No hay eventos sísmicos que coincidan con los filtros aplicados en el período de ${ApiConstants.periodLabels[provider.selectedPeriod]}.',
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.textTheme.bodySmall?.color),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () {
                  provider.setMinMagnitude(0.0);
                  provider.setMaxRadiusKm(null);
                },
                child: const Text('Restablecer Filtros'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80, top: 4),
      itemCount: provider.earthquakes.length,
      itemBuilder: (ctx, index) {
        final eq = provider.earthquakes[index];
        return EarthquakeCard(
          earthquake: eq,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => EarthquakeDetailScreen(
                  earthquake: eq,
                  userLocation: provider.userLocation,
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Limpia y sanitiza el mensaje de error técnico para mostrar solo un texto amigable al usuario.
  String _cleanErrorMessage(String? rawError) {
    if (rawError == null || rawError.isEmpty) {
      return 'No fue posible conectar con el servidor de sismología.';
    }
    if (rawError.contains('SocketException') ||
        rawError.contains('Failed host lookup') ||
        rawError.contains('ClientException') ||
        rawError.contains('UsgsApiException')) {
      return 'No fue posible conectar con el servidor de sismología. Por favor, verifica tu conexión a Internet y vuelve a intentarlo.';
    }
    return rawError;
  }
}
