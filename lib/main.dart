import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/theme/app_theme.dart';
import 'providers/earthquake_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configuración de orientación vertical preferida
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Inicializar símbolos de fecha en español (intl)
  await initializeDateFormatting('es', null);

  // Inicializar Firebase y suscripción a Alertas Push FCM en tiempo real
  try {
    await Firebase.initializeApp();
    debugPrint('🔥 Firebase inicializado con éxito.');

    // Suscribir el dispositivo al Tópico Global de Alertas de Emergencia Sísmica de Colombia
    await FirebaseMessaging.instance.subscribeToTopic('colombia_emergency_alerts');
    debugPrint('📡 Suscrito exitosamente al tópico: colombia_emergency_alerts');

    // Escuchar notificaciones Push cuando el usuario toca la alerta
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('🚨 Notificación Push Tocada: ${message.data}');
    });
  } catch (e) {
    debugPrint('ℹ️ Firebase no configurado aún (Esperando google-services.json/plist): $e');
  }

  runApp(const SismoJimaApp());
}

/// Punto de entrada raíz para la aplicación SismoJima
class SismoJimaApp extends StatelessWidget {
  const SismoJimaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EarthquakeProvider(),
      child: MaterialApp(
        title: 'SismoJima - Sismología Colombia',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system, // Se adapta al modo del dispositivo
        home: const HomeScreen(),
      ),
    );
  }
}
