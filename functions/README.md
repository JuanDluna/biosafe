# Firebase Functions para BioSafe

Este directorio contiene las Cloud Functions de Firebase para enviar notificaciones push automáticas.

## 🚀 Inicio Rápido

```bash
# Instalar dependencias
npm install

# Compilar TypeScript
npm run build

# Desplegar funciones
firebase deploy --only functions
```

## 📦 Estructura

- `src/index.ts` - Código fuente de las funciones (TypeScript)
- `lib/` - Código compilado (generado automáticamente)
- `package.json` - Dependencias del proyecto
- `tsconfig.json` - Configuración de TypeScript

## 🔔 Funciones Disponibles

1. **onMedicineCreatedOrUpdated** - Envía notificación cuando se crea/actualiza un medicamento próximo a vencer
2. **checkExpiringMedicines** - Verificación diaria de medicamentos próximos a vencer
3. **sendDosageReminder** - Función callable para enviar recordatorios de dosis
4. **onFCMTokenUpdated** - Logging cuando se actualiza un token FCM

## 📚 Documentación Completa

Ver `README's/CONFIGURACION_FIREBASE_FUNCTIONS.md` para la documentación completa.

