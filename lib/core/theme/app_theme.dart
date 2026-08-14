import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tema visual moderno y paleta cromática de severidad sísmica para SismoJima
class AppTheme {
  // Paleta de Colores Principales
  static const Color primaryColor = Color(0xFF0F172A); // Slate Dark
  static const Color accentColor = Color(0xFF38BDF8); // Sky Blue
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF334155);

  // Paleta por Severidad Sísmica
  static const Color magLow = Color(0xFF10B981); // Verde (<3.0)
  static const Color magModerate = Color(0xFFF59E0B); // Amarillo/Dorado (3.0 - 4.4)
  static const Color magStrong = Color(0xFFF97316); // Naranja (4.5 - 5.9)
  static const Color magSevere = Color(0xFFEF4444); // Rojo (6.0 - 6.9)
  static const Color magExtreme = Color(0xFF8B5CF6); // Púrpura (>=7.0)

  /// Retorna el color correspondiente según la magnitud del sismo
  static Color getColorForMagnitude(double mag) {
    if (mag < 3.0) return magLow;
    if (mag < 4.5) return magModerate;
    if (mag < 6.0) return magStrong;
    if (mag < 7.0) return magSevere;
    return magExtreme;
  }

  /// Retorna la etiqueta textual descriptiva de intensidad según la magnitud
  static String getLabelForMagnitude(double mag) {
    if (mag < 3.0) return 'Micro / Leve';
    if (mag < 4.5) return 'Moderado';
    if (mag < 6.0) return 'Fuerte';
    if (mag < 7.0) return 'Mayor';
    return 'Desastroso';
  }

  /// Tema Oscuro Premium (Recomendado para sismología)
  static ThemeData get darkTheme {
    final baseTextTheme = ThemeData.dark().textTheme;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: primaryColor,
      colorScheme: const ColorScheme.dark(
        primary: accentColor,
        secondary: Color(0xFF0EA5E9),
        surface: surfaceDark,
        onSurface: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textTheme: GoogleFonts.interTextTheme(baseTextTheme).copyWith(
        headlineMedium: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Tema Claro Elegante
  static ThemeData get lightTheme {
    final baseTextTheme = ThemeData.light().textTheme;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF0284C7),
        secondary: Color(0xFF0369A1),
        surface: Colors.white,
        onSurface: Color(0xFF0F172A),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF0F172A),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textTheme: GoogleFonts.interTextTheme(baseTextTheme),
    );
  }
}
