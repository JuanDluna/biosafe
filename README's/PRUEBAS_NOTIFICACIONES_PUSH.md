# 🧪 Guía de Pruebas - Notificaciones Push con Firebase Functions

Esta guía te ayudará a probar que las notificaciones push están funcionando correctamente.

## ✅ Verificación Inicial

### 1. Verificar que las Functions están desplegadas

En Firebase Console:
1. Ve a **Functions** en el menú lateral
2. Deberías ver 4 funciones desplegadas:
   - `onMedicineCreatedOrUpdated` (Trigger de Firestore)
   - `checkExpiringMedicines` (Scheduled - se ejecuta diariamente)
   - `sendDosageReminder` (Callable - puede ser llamada desde la app)
   - `onFCMTokenUpdated` (Trigger de Firestore)

### 2. Verificar que el token FCM se guarda

1. **Inicia sesión en la app Flutter**
2. Ve a Firebase Console > **Firestore Database**
3. Navega a la colección `users`
4. Abre el documento de tu usuario (tu UID)
5. Verifica que existe el campo `fcm_token` con un valor (debería ser una cadena larga)

**Si no existe el token:**
- Asegúrate de que la app tenga permisos de notificaciones
- En Android: Verifica en Configuración > Apps > BioSafe > Notificaciones
- En iOS: Verifica que se solicitaron los permisos

## 🧪 Pruebas de Notificaciones

### Prueba 1: Notificación al crear medicamento próximo a vencer

1. **Abre la app Flutter**
2. **Agrega un nuevo medicamento** con:
   - Nombre: "Medicamento de Prueba"
   - Fecha de caducidad: **7 días desde hoy** (o menos)
   - Cualquier otra información requerida
3. **Guarda el medicamento**
4. **Deberías recibir una notificación push** inmediatamente con el mensaje de alerta

**Verificar en Firebase Console:**
- Ve a **Functions** > **Logs**
- Busca logs de `onMedicineCreatedOrUpdated`
- Deberías ver: "Notificación de vencimiento enviada a {userId}"

### Prueba 2: Verificación diaria programada

La función `checkExpiringMedicines` se ejecuta automáticamente todos los días a las 9:00 AM (hora de México).

**Para probar manualmente:**

1. Ve a Firebase Console > **Functions**
2. Busca `checkExpiringMedicines`
3. Haz clic en los **tres puntos** (⋮) > **Trigger function**
4. Esto ejecutará la función manualmente
5. Si tienes medicamentos próximos a vencer, deberías recibir notificaciones

**O espera a las 9:00 AM** y verifica los logs al día siguiente.

### Prueba 3: Notificación de dosis (Callable Function)

Esta función puede ser llamada desde la app Flutter. Por ahora, puedes probarla desde Firebase Console:

1. Ve a Firebase Console > **Functions**
2. Busca `sendDosageReminder`
3. Haz clic en los **tres puntos** (⋮) > **Trigger function**
4. Ingresa los parámetros:
   ```json
   {
     "medicineId": "ID_DEL_MEDICAMENTO",
     "medicineName": "Paracetamol",
     "dosageAmount": "1 tableta"
   }
   ```
5. Deberías recibir una notificación push

**Nota:** Para llamar esta función desde la app Flutter, necesitarías agregar código adicional usando `firebase_functions`.

### Prueba 4: Verificar logs de Functions

1. Ve a Firebase Console > **Functions** > **Logs**
2. Busca logs recientes de tus funciones
3. Verifica que no haya errores
4. Los logs deberían mostrar:
   - "Notificación de vencimiento enviada a {userId}"
   - "Ejecutando verificación diaria de medicamentos próximos a vencer"
   - "Token FCM actualizado para usuario {userId}"

## 🔍 Solución de Problemas

### No recibo notificaciones

1. **Verifica el token FCM:**
   - Asegúrate de que `fcm_token` existe en Firestore en `users/{userId}`
   - Si no existe, cierra sesión y vuelve a iniciar sesión

2. **Verifica permisos de notificaciones:**
   - Android: Configuración > Apps > BioSafe > Notificaciones (debe estar habilitado)
   - iOS: Configuración > BioSafe > Notificaciones (debe estar habilitado)

3. **Verifica los logs de Functions:**
   - Ve a Firebase Console > Functions > Logs
   - Busca errores relacionados con FCM o tokens

4. **Verifica que el medicamento cumple los criterios:**
   - Debe vencer en 30 días o menos
   - Debe tener una fecha de vencimiento válida
   - El usuario debe tener un token FCM válido

### Error: "Usuario no tiene token FCM"

1. Cierra sesión en la app
2. Vuelve a iniciar sesión
3. El token debería guardarse automáticamente
4. Verifica en Firestore que el token se guardó

### Error: "Firestore database does not exist"

Si ves este error, significa que la base de datos "biosafe" no está configurada correctamente. Verifica:
1. Que la base de datos "biosafe" existe en Firestore
2. Que las Functions están configuradas para usar esa base de datos

## 📊 Monitoreo

### Ver estadísticas de Functions

1. Ve a Firebase Console > **Functions**
2. Haz clic en una función específica
3. Verás:
   - Número de invocaciones
   - Tiempo de ejecución
   - Errores (si los hay)
   - Logs recientes

### Ver notificaciones enviadas

Las notificaciones se registran en Firestore en la colección `notifications`:
1. Ve a Firebase Console > **Firestore Database**
2. Navega a la colección `notifications`
3. Verás registros de todas las notificaciones enviadas con:
   - `user_id`: ID del usuario
   - `medicine_id`: ID del medicamento
   - `time`: Timestamp de cuando se envió
   - `message`: Mensaje de la notificación
   - `status`: "sent"
   - `type`: "expiration_alert" o "dosage_reminder"

## 🎯 Próximos Pasos

1. **Probar en dispositivo físico** (las notificaciones push no funcionan bien en emuladores)
2. **Configurar notificaciones locales como respaldo** (ya están implementadas en la app)
3. **Personalizar mensajes** de notificación según tus necesidades
4. **Agregar más tipos de notificaciones** si es necesario

## 📝 Notas Importantes

- Las notificaciones push requieren conexión a internet
- Los tokens FCM se renuevan periódicamente y se actualizan automáticamente
- Las funciones programadas se ejecutan en la zona horaria configurada (actualmente "America/Mexico_City")
- Las notificaciones se envían incluso si la app está cerrada (si el dispositivo tiene conexión)

---

**¡Felicidades!** 🎉 Tu sistema de notificaciones push está configurado y funcionando.

