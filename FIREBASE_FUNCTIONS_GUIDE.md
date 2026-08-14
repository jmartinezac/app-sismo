# 📡 Guía Completa de Despliegue de Firebase Cloud Functions y FCM para SismoJima

Esta guía paso a paso te explica cómo poner en producción un servidor **Firebase Cloud Function (Node.js)** que monitorea en tiempo real los sismos en Colombia y envía **Notificaciones Push FCM de Alta Prioridad** a todos los celulares Android e iOS sin gastar batería en los dispositivos.

---

## 🏗️ 1. Crear el Proyecto en Firebase Console

1. Ingresa a la [Consola de Firebase](https://console.firebase.google.com/).
2. Haz clic en **Añadir proyecto** y nombra el proyecto como `SismoJima-Alerts` (anota el ID del proyecto que te asigna Firebase, ej: `sismojima-alerts-12345`).
3. Registra tu aplicación Android:
   - **Nombre de paquete Android**: `com.sismojima.sismo_jima`
   - Descarga el archivo `google-services.json` y colócalo en la carpeta:
     `c:\SismoJima\android\app\google-services.json`
4. Registra tu aplicación iOS:
   - **ID de paquete iOS**: `com.sismojima.sismoJima`
   - Descarga el archivo `GoogleService-Info.plist` y colócalo en la carpeta:
     `c:\SismoJima\ios\Runner\GoogleService-Info.plist`

---

## 📦 2. Instalar herramientas de Firebase CLI

Abre tu terminal en Windows y ejecuta:

```powershell
# 1. Instalar Firebase CLI globalmente
npm install -g firebase-tools

# 2. Iniciar sesión en tu cuenta de Google / Firebase
firebase login
```

---

## 🚀 3. Desplegar la Cloud Function

He creado los archivos **`firebase.json`** en la carpeta `c:\SismoJima\server\functions`.

Para desplegar a la nube, ejecuta en tu terminal:

```powershell
# 1. Navegar a la carpeta del servidor
cd c:\SismoJima\server\functions

# 2. Vincular tu proyecto de Firebase (Reemplaza 'ID_DE_TU_PROYECTO' por el ID de Firebase Console)
firebase use --add

# O simplemente desplegar especificando el ID de tu proyecto:
firebase deploy --only functions --project ID_DE_TU_PROYECTO
```

---

## 📱 4. Conectar la Aplicación Flutter (Cliente FCM)

### Paso A: Agregar dependencias en `pubspec.yaml`
```yaml
dependencies:
  firebase_core: ^3.10.0
  firebase_messaging: ^15.2.0
```

### Paso B: Suscribir el dispositivo al Tópico de Alertas en `main.dart`
En el punto de entrada de la app, añade la suscripción al tópico global de Colombia:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Suscribir el celular al tópico de Alertas de Emergencia Sísmica de Colombia
  await FirebaseMessaging.instance.subscribeToTopic('colombia_emergency_alerts');

  // Escuchar notificaciones Push en segundo plano o app cerrada
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('🚨 Notificación Push Tocada: ${message.data}');
  });

  runApp(const SismoJimaApp());
}
```

---

## ⚡ ¿Cómo Funciona la Alerta Instantánea?

```text
               [USGS / RSNC Stream]
                        │
                        ▼
     [Firebase Cloud Function (Google Cloud)]
(Monitoreo 24/7 de Colombia Lat -4.2° a 13.5°)
                        │
                        ▼ (Si M ≥ 3.5 en Colombia)
  [Firebase Cloud Messaging (FCM Push High Priority)]
                        │
                        ▼
      [Celulares Android / iOS Suscritos]
🚨 Notificación Flotante con Sonido y Vibración de Evacuación
(Despierta la pantalla con la app cerrada y consumo 0% de batería)
```
