import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/earthquake_provider.dart';

/// Insignia con animación de pulso que indica el Estado del Monitoreo en Tiempo Real (WebSocket Live 0s / Polling)
class RealTimeStatusBadge extends StatefulWidget {
  const RealTimeStatusBadge({super.key});

  @override
  State<RealTimeStatusBadge> createState() => _RealTimeStatusBadgeState();
}

class _RealTimeStatusBadgeState extends State<RealTimeStatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EarthquakeProvider>(context);
    final theme = Theme.of(context);
    final bool isWsActive = provider.isWebSocketConnected;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isWsActive
            ? Colors.cyan.withValues(alpha: 0.15)
            : Colors.green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isWsActive
              ? Colors.cyan.withValues(alpha: 0.5)
              : Colors.green.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: _animation,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isWsActive ? Colors.cyanAccent : Colors.green,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isWsActive ? 'WebSocket Live (0s)' : 'Tiempo Real (${provider.pollingIntervalSeconds}s)',
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: theme.brightness == Brightness.dark
                  ? (isWsActive ? Colors.cyanAccent : Colors.greenAccent)
                  : (isWsActive ? Colors.cyan.shade900 : Colors.green.shade800),
            ),
          ),
        ],
      ),
    );
  }
}
