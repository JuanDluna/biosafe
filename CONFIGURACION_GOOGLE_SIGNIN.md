# Configuración de Google Sign In para BioSafe

## 📋 Configuraciones Necesarias

### 1. Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto `biosafe-d1a94`
3. Ve a **Authentication** > **Sign-in method**
4. Habilita **Google** como proveedor de autenticación
5. Configura el email de soporte y el nombre del proyecto público
6. Guarda los cambios

### 2. Android - Configuración

#### a) SHA-1 Fingerprint

Necesitas obtener el SHA-1 de tu certificado de depuración:

**Windows:**
```bash
cd android
gradlew signingReport
```

O manualmente:
```bash
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

**macOS/Linux:**
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

#### b) Agregar SHA-1 a Firebase

1. Copia el SHA-1 fingerprint (sin los dos puntos)
2. Ve a Firebase Console > Project Settings > Your apps
3. Selecciona tu app Android
4. Agrega el SHA-1 fingerprint en la sección "SHA certificate fingerprints"
5. Descarga el nuevo `google-services.json` y reemplázalo en `android/app/`

#### c) Verificar build.gradle

Asegúrate de que `android/app/build.gradle` tenga:

```gradle
android {
    defaultConfig {
        applicationId "com.example.biosafe"
        // ... otras configuraciones
    }
}
```

### 3. iOS - Configuración

#### a) Configurar URL Scheme

En `ios/Runner/Info.plist`, agrega:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.TU_CLIENT_ID_INVERSO</string>
        </array>
    </dict>
</array>
```

#### b) Obtener Client ID

1. Ve a Firebase Console > Project Settings > Your apps
2. Selecciona tu app iOS
3. Copia el **REVERSED_CLIENT_ID** del `GoogleService-Info.plist`
4. Úsalo en el URL Scheme arriba

#### c) Verificar GoogleService-Info.plist

Asegúrate de tener el archivo `GoogleService-Info.plist` en `ios/Runner/`

### 4. Web - Configuración

Si planeas usar la app en Web:

1. Ve a Firebase Console > Project Settings > Your apps
2. Selecciona tu app Web (o créala si no existe)
3. Copia el **Web API Key**
4. Agrega el dominio autorizado en Firebase Console > Authentication > Settings > Authorized domains

### 5. Verificar Dependencias

Asegúrate de que `pubspec.yaml` tenga:

```yaml
dependencies:
  google_sign_in: ^6.2.1
```

Ejecuta:
```bash
flutter pub get
```

### 6. Probar la Autenticación

1. Ejecuta la app: `flutter run`
2. En la pantalla de login, toca "Continuar con Google"
3. Debería abrirse el selector de cuenta de Google
4. Selecciona una cuenta y autoriza

## 🔧 Solución de Problemas

### Error: "DEVELOPER_ERROR" en Android

- Verifica que el SHA-1 esté correctamente agregado en Firebase
- Asegúrate de haber descargado el nuevo `google-services.json`
- Limpia y reconstruye: `flutter clean && flutter pub get && flutter run`

### Error: "PlatformException" en iOS

- Verifica que el URL Scheme esté correctamente configurado en Info.plist
- Asegúrate de tener el `GoogleService-Info.plist` correcto
- Verifica que el Bundle ID coincida con Firebase

### Error: "Network Error" o "Sign in cancelled"

- Verifica tu conexión a internet
- Asegúrate de que Google Sign In esté habilitado en Firebase Console
- Verifica que el OAuth consent screen esté configurado en Google Cloud Console

## 📝 Notas Importantes

- El SHA-1 de depuración es diferente al de producción
- Necesitarás agregar el SHA-1 de producción cuando generes el APK/AAB
- Para producción, obtén el SHA-1 del keystore de firma:
  ```bash
  keytool -list -v -keystore ruta/a/tu/keystore.jks -alias tu_alias
  ```

## ✅ Checklist de Configuración

- [ ] Google Sign In habilitado en Firebase Console
- [ ] SHA-1 fingerprint agregado en Firebase (Android)
- [ ] `google-services.json` actualizado en `android/app/`
- [ ] URL Scheme configurado en `Info.plist` (iOS)
- [ ] `GoogleService-Info.plist` presente en `ios/Runner/` (iOS)
- [ ] Dominios autorizados configurados (Web)
- [ ] `google_sign_in` agregado en `pubspec.yaml`
- [ ] `flutter pub get` ejecutado
- [ ] App probada en dispositivo/emulador


