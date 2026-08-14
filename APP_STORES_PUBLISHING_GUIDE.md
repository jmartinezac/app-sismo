# 🚀 Guía Paso a Paso para Publicación y Distribución Directa de SismoJima

Esta guía detallada te explica cómo firmar, compilar y subir **SismoJima** a las tiendas oficiales (**Google Play Store** y **Apple App Store**), así como la generación e instalación directa de archivos ejecutables independientes en teléfonos Android e iPhones sin pasar por las tiendas públicas.

---

## 🤖 PARTE 1: Publicación en Google Play Store (Android)

Para publicar en Google Play Store, Google requiere la entrega de un formato **Android App Bundle (`.aab`)** firmado con una clave criptográfica de producción (*Keystore*).

### Paso 1: Generar la Clave de Firma (Keystore) de Producción
Abre la consola de comandos de Windows (CMD o PowerShell) y ejecuta:

```powershell
keytool -genkey -v -keystore c:\SismoJima\android\app\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
*Te pedirá ingresar una contraseña segura y datos básicos (Nombre, Organización, País).*

---

### Paso 2: Configurar las Credenciales en `android/key.properties`
Crea un archivo llamado `key.properties` en la carpeta `c:\SismoJima\android\` con el siguiente contenido:

```ini
storePassword=TU_CONTRASEÑA_DE_KEYSTORE
keyPassword=TU_CONTRASEÑA_DE_CLAVE
keyAlias=upload
storeFile=../app/upload-keystore.jks
```

---

### Paso 3: Compilar el Paquete de Producción (`.aab`)
En tu terminal de PowerShell en `c:\SismoJima`, ejecuta:

```powershell
flutter build appbundle --release
```

**Resultado de Compilación**:
El paquete `.aab` firmado se generará en:
`c:\SismoJima\build\app\outputs\bundle\release\app-release.aab`

---

### Paso 4: Subir a Google Play Console
1. Entra a [Google Play Console](https://play.google.com/console) e inicia sesión con tu cuenta de desarrollador de Google.
2. Haz clic en **Crear aplicación**:
   - Nombre: `SismoJima - Alertas Sísmicas`
   - Idioma predeterminado: `Español`
3. Ve al menú **Producción** -> **Crear nueva versión**.
4. Sube el archivo `app-release.aab` que compilaste.
5. Completa la Ficha de la tienda (descripción, capturas de pantalla de la app e ícono de 512x512 px) y envía a revisión.

---

## 🍎 PARTE 2: Publicación en Apple App Store (iOS)

Para publicar en la tienda de Apple, debes compilar el paquete `.ipa` utilizando **Xcode** en una computadora con sistema operativo **macOS** y disponer de una cuenta de **Apple Developer Program** ($99 USD/año).

### Paso 1: Configurar el Identificador en Apple Developer
1. Ingresa a [developer.apple.com](https://developer.apple.com/) -> **Certificates, Identifiers & Profiles**.
2. Registra el **App ID**: `com.sismojima.sismoJima`.
3. Habilita los servicios de **Push Notifications** y **Background Modes**.

---

### Paso 2: Abrir el Proyecto en Xcode (macOS)
En tu computadora Mac, abre el espacio de trabajo del proyecto:

```bash
open ios/Runner.xcworkspace
```

1. En el panel izquierdo de Xcode, selecciona **Runner**.
2. En la pestaña **Signing & Capabilities**:
   - Selecciona tu Equipo de Desarrollador (*Team*).
   - Verifica que el Bundle Identifier sea `com.sismojima.sismoJima`.

---

### Paso 3: Compilar el Paquete `.ipa` de Producción
En la terminal de la Mac en la carpeta `c:/SismoJima`, ejecuta:

```bash
flutter build ipa --release
```

**Resultado**:
El paquete de distribución se generará en:
`build/ios/archive/Runner.xcarchive`

---

### Paso 4: Subir a App Store Connect
1. Abre **Xcode** -> Menú **Product** -> **Archive**.
2. Selecciona la versión compilada y haz clic en **Distribute App**.
3. Selecciona **App Store Connect** -> **Upload**.
4. Abre [appstoreconnect.apple.com](https://appstoreconnect.apple.com/), completa los metadatos (capturas para iPhone/iPad, política de privacidad) y presiona **Enviar para revisión de App Store**.

---

## 📲 PARTE 3: Instalación y Distribución Directa (Sin Publicar en Tiendas)

Si deseas compartir la aplicación directamente con usuarios o equipos de trabajo sin subirla a las tiendas públicas:

### 🤖 A. Distribución Directa en Android (Archivo `.apk`)

1. **Compilar el archivo ejecutable `.apk`**:
   ```powershell
   flutter build apk --release
   ```
2. **Ubicación del archivo generado**:
   `c:\SismoJima\build\app\outputs\flutter-apk\app-release.apk`
3. **Instalación en dispositivos**:
   - Comparte el archivo `app-release.apk` por WhatsApp, Telegram, Google Drive o correo.
   - La persona toca el archivo en su celular Android.
   - Si el teléfono lo solicita, activa la casilla *"Permitir instalar desde fuentes desconocidas"*.
   - ¡Listo! La app queda instalada en el teléfono.

---

### 🍎 B. Distribución Directa en iOS / iPhone (Sin App Store Pública)

Apple requiere métodos específicos de distribución privada debido a la seguridad del sistema iOS:

1. **Método 1: TestFlight (Recomendado y gratuito)**:
   - Subes la versión beta a TestFlight en App Store Connect.
   - Generas un enlace web público/privado de invitación.
   - Los usuarios abren el enlace en su iPhone e instalan la aplicación con 1 clic sin revisión pública de la App Store.

2. **Método 2: Distribución Ad-Hoc / Empresa (`.ipa`)**:
   - Registras los identificadores (UDID) de los iPhones de tu equipo en [developer.apple.com](https://developer.apple.com/).
   - Compilas el archivo `.ipa` firmado para esos dispositivos específicos e instalas vía web privada.

3. **Método 3: Instalación Directa por Cable USB (Xcode)**:
   - Conectas el iPhone por cable USB a una Mac.
   - En Xcode seleccionas el iPhone conectado y presionas **Run**. La aplicación se instala directamente en el dispositivo.

---

## 📊 Resumen de Comandos de Compilación

| Tienda / Objetivo | Comando Flutter | Archivo Resultado |
| :--- | :--- | :--- |
| 🤖 **Google Play Store** | `flutter build appbundle --release` | `build/app/outputs/bundle/release/app-release.aab` |
| 🤖 **APK Directo (Instalación libre)** | `flutter build apk --release` | `build/app/outputs/flutter-apk/app-release.apk` |
| 🍎 **Apple App Store / TestFlight** | `flutter build ipa --release` | `build/ios/archive/Runner.xcarchive` / `.ipa` |
