# Solución: Error de Permisos de Firestore

## Problema

Al intentar guardar un medicamento, aparece el siguiente error:

```
PERMISSION_DENIED: Cloud Firestore API has not been used in project biosafe-d1a94 before or it is disabled.
```

## Solución

Este error indica que la API de Cloud Firestore no está habilitada en tu proyecto de Firebase. Sigue estos pasos:

### Paso 1: Habilitar la API de Firestore

1. Ve a la [Consola de Google Cloud](https://console.cloud.google.com/)
2. Selecciona tu proyecto: `biosafe-d1a94`
3. Ve a **APIs & Services** > **Library**
4. Busca "Cloud Firestore API"
5. Haz clic en **Enable** (Habilitar)

**O directamente:**

Haz clic en este enlace (reemplaza `biosafe-d1a94` con tu ID de proyecto si es diferente):
```
https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=biosafe-d1a94
```

### Paso 2: Configurar Reglas de Seguridad de Firestore

1. Ve a la [Consola de Firebase](https://console.firebase.google.com/)
2. Selecciona tu proyecto `biosafe-d1a94`
3. Ve a **Firestore Database** > **Rules**
4. Asegúrate de que las reglas permitan lectura/escritura para usuarios autenticados:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Permitir lectura y escritura solo a usuarios autenticados
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
    
    // Reglas específicas para medicamentos
    match /medicines/{medicineId} {
      allow read, write: if request.auth != null 
        && request.auth.uid == resource.data.user_id;
    }
    
    // Reglas específicas para usuarios
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Reglas específicas para tratamientos
    match /treatments/{treatmentId} {
      allow read, write: if request.auth != null 
        && request.auth.uid == resource.data.user_id;
    }
    
    // Reglas específicas para notificaciones
    match /notifications/{notificationId} {
      allow read, write: if request.auth != null 
        && request.auth.uid == resource.data.user_id;
    }
  }
}
```

5. Haz clic en **Publish** (Publicar)

### Paso 3: Verificar que Firestore esté en modo de producción

1. En la consola de Firebase, ve a **Firestore Database**
2. Si aparece un mensaje para crear la base de datos, haz clic en **Create database**
3. Selecciona **Start in production mode** (o usa las reglas del Paso 2)
4. Selecciona una ubicación para tu base de datos (recomendado: `us-central` o la más cercana a tu ubicación)

### Paso 4: Esperar la propagación

Después de habilitar la API, espera 2-5 minutos para que los cambios se propaguen.

### Paso 5: Probar nuevamente

1. Cierra completamente la app
2. Vuelve a ejecutarla: `flutter run`
3. Intenta agregar un medicamento nuevamente

## Nota Importante

Si el problema persiste después de seguir estos pasos:

1. Verifica que estés usando el proyecto correcto de Firebase
2. Verifica que el archivo `firebase_options.dart` tenga la configuración correcta
3. Verifica que el usuario esté autenticado correctamente
4. Revisa los logs de Firebase Console para ver si hay más detalles del error

## Verificación Rápida

Para verificar que Firestore está habilitado:

1. Ve a [APIs & Services](https://console.cloud.google.com/apis/dashboard)
2. Busca "Cloud Firestore API"
3. Debe aparecer como **Enabled** (Habilitado)

