# 🔧 Configuración de Firebase Functions para Notificaciones Push

Esta guía te ayudará a configurar Firebase Functions para enviar notificaciones push automáticas en BioSafe.

## 📋 Requisitos Previos

1. **Node.js y npm** instalados (versión 20 o superior)
   - Verificar: `node --version` y `npm --version`
   - **Nota**: Node.js 18 fue descontinuado. Se requiere Node.js 20 o superior.
2. **Firebase CLI** instalado globalmente
   - Instalar: `npm install -g firebase-tools`
   - Verificar: `firebase --version`
3. **Proyecto Firebase** configurado
4. **Cuenta de Firebase** con plan Blaze (requerido para Functions)

## 🚀 Pasos de Configuración

### 1. Inicializar Firebase Functions

Si aún no has inicializado Firebase Functions en tu proyecto:

```bash
# Desde la raíz del proyecto
cd functions
npm install
```

### 2. Configurar Firebase CLI

```bash
# Iniciar sesión en Firebase
firebase login

# Seleccionar tu proyecto
firebase use --add

# Seleccionar el proyecto "biosafe-d1a94" (o el ID de tu proyecto)
```

### 3. Habilitar APIs Necesarias

En la [Consola de Google Cloud](https://console.cloud.google.com/):

1. Ve a **APIs & Services** > **Library**
2. Busca y habilita las siguientes APIs:
   - **Cloud Functions API**
   - **Cloud Firestore API** (si no está habilitada)
   - **Cloud Messaging API** (FCM)

### 4. Configurar Permisos de Firestore

Las Functions necesitan permisos para leer y escribir en Firestore. Esto se configura automáticamente cuando despliegas las funciones, pero asegúrate de que:

1. En Firebase Console > **Firestore Database** > **Rules**, las reglas permitan lectura/escritura para usuarios autenticados
2. Las Functions tienen permisos de administrador (se configuran automáticamente)

### 5. Desplegar Functions

```bash
# Desde la raíz del proyecto
firebase deploy --only functions
```

Esto desplegará todas las funciones definidas en `functions/src/index.ts`.

## 📱 Funciones Disponibles

### 1. `onMedicineCreatedOrUpdated`
- **Tipo**: Firestore Trigger
- **Evento**: Se ejecuta cuando se crea o actualiza un medicamento
- **Acción**: Verifica si el medicamento está próximo a vencer y envía notificación push

### 2. `checkExpiringMedicines`
- **Tipo**: Scheduled Function (Cloud Scheduler)
- **Frecuencia**: Diaria a las 9:00 AM (zona horaria configurable)
- **Acción**: Verifica todos los medicamentos próximos a vencer y envía notificaciones

### 3. `sendDosageReminder`
- **Tipo**: Callable Function (HTTP)
- **Uso**: Puede ser llamada desde la app Flutter para enviar recordatorios de dosis
- **Autenticación**: Requiere usuario autenticado

### 4. `onFCMTokenUpdated`
- **Tipo**: Firestore Trigger
- **Evento**: Se ejecuta cuando se actualiza el token FCM de un usuario
- **Uso**: Para debugging y logging

## 🔔 Configuración de Notificaciones en la App Flutter

### 1. El token FCM se guarda automáticamente

Cuando un usuario inicia sesión, el token FCM se obtiene y guarda automáticamente en Firestore en el documento del usuario (`users/{userId}`) con el campo `fcm_token`.

### 2. Verificar que el token se guarda

1. Inicia sesión en la app
2. Ve a Firebase Console > **Firestore Database**
3. Busca la colección `users` y el documento de tu usuario
4. Verifica que existe el campo `fcm_token` con un valor

### 3. Probar notificaciones

**Opción A: Crear un medicamento próximo a vencer**
1. Crea un medicamento con fecha de vencimiento dentro de 7 días
2. Deberías recibir una notificación push automáticamente

**Opción B: Esperar la verificación diaria**
- La función `checkExpiringMedicines` se ejecuta diariamente a las 9:00 AM
- Verifica todos los medicamentos próximos a vencer

**Opción C: Usar la función callable**
- Desde la app, puedes llamar a `sendDosageReminder` para enviar un recordatorio manual

## 🛠️ Desarrollo Local

### Ejecutar Functions localmente

```bash
# Instalar dependencias
cd functions
npm install

# Compilar TypeScript
npm run build

# Ejecutar emulador local
firebase emulators:start --only functions
```

### Ver logs de Functions

```bash
# Ver logs en tiempo real
firebase functions:log

# Ver logs de una función específica
firebase functions:log --only onMedicineCreatedOrUpdated
```

## 📝 Personalización

### Cambiar zona horaria de la función programada

Edita `functions/src/index.ts`:

```typescript
export const checkExpiringMedicines = functions.pubsub
  .schedule("0 9 * * *") // 9:00 AM
  .timeZone("America/Mexico_City") // Cambiar aquí
  .onRun(async (context) => {
    // ...
  });
```

Zonas horarias comunes:
- `America/Mexico_City` - México
- `America/New_York` - Este de EE.UU.
- `Europe/Madrid` - España
- `America/Los_Angeles` - Oeste de EE.UU.

### Modificar mensajes de notificación

Edita los títulos y cuerpos de los mensajes en `functions/src/index.ts`:

```typescript
const title = "💊 Recordatorio: Es hora de tomar tu medicamento";
const body = `Es hora de tomar: ${dosageAmount} de ${medicineName}`;
```

## ⚠️ Solución de Problemas

### Error: "Permission denied"
- Verifica que las reglas de Firestore permitan lectura/escritura
- Asegúrate de que el usuario esté autenticado

### Error: "Function failed to deploy"
- Verifica que Node.js esté en versión 18 o superior
- Ejecuta `npm install` en la carpeta `functions`
- Verifica que todas las APIs estén habilitadas

### No se reciben notificaciones
1. Verifica que el token FCM esté guardado en Firestore
2. Verifica los logs de Functions: `firebase functions:log`
3. Asegúrate de que la app tenga permisos de notificaciones
4. Verifica que el dispositivo tenga conexión a internet

### Token FCM no se guarda
1. Verifica que el usuario esté autenticado
2. Revisa los logs de la app Flutter
3. Verifica que `NotificationService` se inicialice correctamente

## 📚 Recursos Adicionales

- [Documentación de Firebase Functions](https://firebase.google.com/docs/functions)
- [Documentación de Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)
- [Guía de TypeScript para Functions](https://firebase.google.com/docs/functions/typescript)

## 🔐 Seguridad

- Las Functions tienen acceso completo a Firestore (admin SDK)
- Las funciones callable requieren autenticación
- Los tokens FCM son específicos por usuario y dispositivo
- Los tokens se renuevan automáticamente y se actualizan en Firestore

## 💰 Costos

Firebase Functions tiene un plan gratuito generoso:
- **2 millones de invocaciones/mes** gratis
- **400,000 GB-segundos de tiempo de cómputo/mes** gratis
- **200,000 GB-segundos de tiempo de cómputo fuera de red/mes** gratis

Para la mayoría de aplicaciones pequeñas/medianas, esto es suficiente.

---

**Nota**: Asegúrate de tener el plan **Blaze** (pay-as-you-go) activado en Firebase, ya que es requerido para usar Cloud Functions, aunque puedes permanecer dentro del plan gratuito.

