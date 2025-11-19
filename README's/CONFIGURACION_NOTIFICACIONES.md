# Configuración de Notificaciones Push - BioSafe

## 📱 Notificaciones Locales (Sin Backend)

BioSafe utiliza **notificaciones locales programadas** que funcionan completamente sin necesidad de un backend. Estas notificaciones se programan directamente en el dispositivo.

### ✅ Funcionalidades Implementadas

1. **Recordatorios de Dosis Temporizada**
   - Se programan automáticamente cuando agregas un medicamento con dosis temporizada
   - Calcula todas las notificaciones basándose en:
     - Cantidad de dosis (ej: "1 tableta")
     - Intervalo en horas (ej: cada 8 horas)
     - Duración en días (ej: 7 días)
   - Las notificaciones se cancelan automáticamente si eliminas o modificas el medicamento

2. **Alertas de Vencimiento**
   - Se programan automáticamente para medicamentos próximos a vencer
   - Alertas diferenciadas:
     - 🔴 **Crítica**: Vence en 7 días o menos
     - 🟡 **Advertencia**: Vence en 8-30 días
     - ⚠️ **Vencido**: Medicamento ya vencido
   - Se verifican automáticamente al cargar los medicamentos

### 🔧 Configuración Requerida

#### Android

1. **Permisos en AndroidManifest.xml**

   Ya están configurados en `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
   ```

2. **Configuración de Notificaciones Exactas**

   Para Android 12+ (API 31+), las notificaciones programadas requieren permisos especiales. El código ya está configurado para usar `AndroidScheduleMode.exactAllowWhileIdle`.

3. **Canal de Notificaciones**

   El canal `biosafe_channel` se crea automáticamente con:
   - Nombre: "BioSafe Notificaciones"
   - Importancia: Alta
   - Prioridad: Alta

#### iOS

1. **Permisos en Info.plist**

   Los permisos se solicitan automáticamente al inicializar la app. Asegúrate de que en `ios/Runner/Info.plist` tengas:

   ```xml
   <key>UIBackgroundModes</key>
   <array>
       <string>remote-notification</string>
   </array>
   ```

2. **Capabilities**

   En Xcode, verifica que la app tenga habilitado:
   - Push Notifications (si planeas usar FCM en el futuro)
   - Background Modes > Remote notifications

### 📋 Cómo Funciona

#### Programación Automática

Cuando agregas o actualizas un medicamento:

1. **Si tiene dosis temporizada:**
   - Se calculan todas las notificaciones necesarias
   - Se programan usando `timezone` para manejar correctamente las zonas horarias
   - Cada notificación tiene un ID único basado en el ID del medicamento

2. **Para alertas de vencimiento:**
   - Se verifica si el medicamento está próximo a vencer (dentro de 30 días)
   - Se programa una alerta para el día de vencimiento a las 9:00 AM
   - Se actualiza automáticamente si modificas la fecha de vencimiento

#### Cancelación Automática

- Al eliminar un medicamento: Se cancelan todas sus notificaciones
- Al actualizar un medicamento: Se cancelan las notificaciones anteriores y se crean nuevas
- Al cargar medicamentos: Se verifican y actualizan las alertas de vencimiento

### 🧪 Pruebas

#### Probar Recordatorios de Dosis

1. Agrega un medicamento con dosis temporizada:
   - Activa el switch "Dosis Temporizada"
   - Ingresa: "1 tableta" cada "2 horas" durante "1 día"
   - Guarda el medicamento

2. Verifica las notificaciones:
   - Deberías recibir notificaciones cada 2 horas
   - Las notificaciones aparecerán incluso si la app está cerrada

#### Probar Alertas de Vencimiento

1. Agrega un medicamento con fecha de vencimiento próxima:
   - Establece la fecha de caducidad a 5 días en el futuro
   - Guarda el medicamento

2. Verifica la alerta:
   - Deberías recibir una notificación el día de vencimiento a las 9:00 AM
   - El mensaje indicará que el medicamento vence hoy

### 🔔 Notificaciones Push Remotas (Opcional - Requiere Backend)

Si en el futuro quieres usar notificaciones push remotas desde Firebase Cloud Messaging (FCM), necesitarás:

1. **Firebase Cloud Functions** (Backend serverless)
   - Para enviar notificaciones automáticamente
   - Para programar notificaciones basadas en eventos

2. **Configuración adicional:**
   - Token FCM ya se obtiene automáticamente
   - Puedes guardarlo en Firestore para enviar notificaciones remotas
   - Requiere configuración de Cloud Functions

### ⚠️ Limitaciones Actuales

1. **Notificaciones Locales:**
   - Funcionan solo en el dispositivo donde se programaron
   - Se pierden si desinstalas la app
   - Requieren que la app se haya ejecutado al menos una vez

2. **Límites del Sistema:**
   - Android tiene límites en el número de notificaciones programadas
   - iOS puede cancelar notificaciones si hay demasiadas
   - Se recomienda no programar más de 1000 notificaciones por medicamento

### 🛠️ Solución de Problemas

#### Las notificaciones no aparecen

1. **Verifica permisos:**
   - Android: Ve a Configuración > Apps > BioSafe > Notificaciones
   - iOS: Ve a Configuración > BioSafe > Notificaciones

2. **Verifica que la app esté inicializada:**
   - Las notificaciones se programan cuando agregas/actualizas medicamentos
   - Asegúrate de que el servicio de notificaciones se haya inicializado en `main.dart`

3. **Verifica la zona horaria:**
   - Las notificaciones usan la zona horaria local del dispositivo
   - Si cambias la zona horaria, las notificaciones se ajustan automáticamente

#### Las notificaciones se cancelan solas

- Esto puede ocurrir si el sistema operativo necesita liberar recursos
- Las notificaciones se reprograman automáticamente al cargar los medicamentos
- Considera reducir el número de notificaciones programadas

### 📝 Notas Técnicas

- **Paquete usado:** `flutter_local_notifications` + `timezone`
- **Método de programación:** `zonedSchedule` con `AndroidScheduleMode.exactAllowWhileIdle`
- **IDs de notificaciones:** Basados en hash del ID del medicamento para garantizar unicidad
- **Persistencia:** Las notificaciones se guardan en Firestore (opcional) y se programan localmente

### ✅ Checklist de Configuración

- [x] Dependencias agregadas (`flutter_local_notifications`, `timezone`)
- [x] Servicio de notificaciones inicializado en `main.dart`
- [x] Permisos configurados en AndroidManifest.xml
- [x] Integración en MedicineProvider para programación automática
- [ ] Probar notificaciones de dosis temporizada
- [ ] Probar alertas de vencimiento
- [ ] Verificar permisos en dispositivo

