import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';

/// Insignia visual circular para representar la magnitud del sismo con colores dinámicos
class MagnitudeBadge extends StatelessWidget {
  final double magnitude;
  final double size;

  const MagnitudeBadge({
    super.key,
    required this.magnitude,
    this.size = 56.0,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getColorForMagnitude(magnitude);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.15),
        border: Border.all(
          color: color,
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Text(
          magnitude > 0 ? magnitude.toStringAsFixed(1) : '?',
          style: GoogleFonts.outfit(
            fontSize: size * 0.38,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}
