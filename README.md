# 🏥 BioSafe - Control de Medicamentos

**BioSafe** es una aplicación móvil multiplataforma (Android, iOS y Web) desarrollada en Flutter enfocada en adultos mayores para el control y gestión de medicamentos. Incluye funcionalidades de escaneo OCR con IA, lectura de códigos de barras, sincronización en la nube con Firebase, y un sistema de recordatorios accesible.

## 📱 Características Principales

- ✅ **Autenticación Completa**: Inicio de sesión con Google Sign In y Email/Contraseña
- 💊 **Gestión de Medicamentos**: Añade, edita y elimina medicamentos con información completa
- 📸 **Escaneo OCR**: Captura y reconoce texto de medicamentos usando Google ML Kit
- 🔍 **Lectura de Códigos**: Escanea códigos de barras para búsqueda automática
- ⚠️ **Alertas de Caducidad**: Avisos para medicamentos próximos a vencer o vencidos
- 🔔 **Notificaciones**: Recordatorios push y locales para toma de medicamentos
- 👨‍👩‍👧 **Gestión Familiar**: Vincula familiares para supervisión médica
- 🩸 **Tratamientos Especiales**: Registro de glucosa, presión arterial y otros tratamientos
- 🔊 **Text-to-Speech**: Lectura de voz para mejorar accesibilidad
- 💾 **Sincronización Offline**: Base de datos SQLite local con sincronización automática con Firestore
- 🎨 **Diseño Accesible**: UI optimizada para adultos mayores con fuentes grandes y alto contraste
- 🌐 **Multiplataforma**: Compatible con Android, iOS y Web

## 🛠️ Tecnologías Utilizadas

### Frontend
- **Flutter** (3.9.2+) - Framework multiplataforma
- **Dart** - Lenguaje de programación
- **Provider** - Gestión de estado
- **FontAwesome** - Iconos

### Backend y Servicios
- **Firebase Core** - Plataforma backend
- **Firebase Auth** - Autenticación de usuarios
- **Cloud Firestore** - Base de datos NoSQL en tiempo real
- **Firebase Storage** - Almacenamiento de imágenes
- **Firebase Cloud Messaging** - Notificaciones push
- **Google Sign In** - Autenticación con Google

### Funcionalidades Locales
- **SQLite** (sqflite) - Base de datos local offline
- **Google ML Kit** - Reconocimiento óptico de caracteres (OCR)
- **Mobile Scanner** - Escaneo de códigos de barras
- **Flutter TTS** - Text-to-Speech para accesibilidad
- **Image Picker** - Captura de imágenes
- **Flutter Local Notifications** - Notificaciones locales
- **Shared Preferences** - Almacenamiento de preferencias

### Utilidades
- **FL Chart** - Gráficos para tratamientos
- **Intl** - Internacionalización y formato de fechas

## 🚀 Instalación y Ejecución

### Requisitos Previos

- Flutter SDK (versión 3.9.2 o superior)
- Dart SDK
- Android Studio / Visual Studio Code / Xcode (para iOS)
- Cuenta de Firebase con proyecto configurado
- Un dispositivo Android/iOS físico o emulador

### Configuración de Firebase

1. **Crear proyecto en Firebase Console**
   - Ve a [Firebase Console](https://console.firebase.google.com/)
   - Crea un nuevo proyecto o usa el existente `biosafe-d1a94`
   - Habilita Authentication con Email/Password y Google Sign In
   - Configura Cloud Firestore

2. **Android**
   - Descarga `google-services.json` desde Firebase Console
   - Colócalo en `android/app/google-services.json`
   - Agrega tu SHA-1 fingerprint en Firebase Console > Project Settings

3. **iOS**
   - Descarga `GoogleService-Info.plist` desde Firebase Console
   - Colócalo en `ios/Runner/GoogleService-Info.plist`
   - Configura el URL Scheme en `ios/Runner/Info.plist`

Para más detalles, consulta `CONFIGURACION_GOOGLE_SIGNIN.md`.

### Pasos para Ejecutar

1. **Clonar el repositorio**
```bash
git clone [url-del-repositorio]
cd biosafe
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Configurar Firebase**
   - Asegúrate de tener los archivos de configuración de Firebase en su lugar
   - Verifica que `firebase_options.dart` esté actualizado

4. **Ejecutar la aplicación**
```bash
# Android
flutter run

# iOS
flutter run -d ios

# Web
flutter run -d chrome
```

## 📂 Estructura del Proyecto

```
lib/
├── main.dart                          # Punto de entrada con inicialización de Firebase
├── firebase_options.dart              # Configuración de Firebase para todas las plataformas
├── models/
│   ├── medicine_model.dart           # Modelo de medicamento
│   ├── user_model.dart               # Modelo de usuario
│   ├── treatment_model.dart          # Modelo de tratamiento
│   └── notification_model.dart       # Modelo de notificación
├── screens/
│   ├── login_screen.dart             # Pantalla de autenticación (Google + Email)
│   ├── home_screen.dart              # Pantalla principal con navegación
│   ├── inventory_screen.dart         # Inventario completo con filtros
│   ├── add_medicine_screen.dart      # Agregar/Editar medicamento (OCR + Barcode)
│   ├── notifications_screen.dart     # Recordatorios y notificaciones
│   ├── family_screen.dart            # Gestión de familiares
│   └── settings_screen.dart          # Configuración y accesibilidad
├── services/
│   ├── auth_service.dart            # Autenticación (Firebase Auth + Google Sign In)
│   ├── firestore_service.dart        # CRUD en Cloud Firestore
│   ├── database_service.dart         # Base de datos local SQLite
│   ├── notification_service.dart     # Notificaciones push y locales
│   ├── ocr_service.dart             # Reconocimiento óptico de caracteres
│   ├── barcode_service.dart         # Escaneo de códigos de barras
│   └── scanner_service.dart         # Servicio de escaneo (compatibilidad)
├── providers/
│   ├── auth_provider.dart           # Provider de autenticación
│   └── medicine_provider.dart       # Provider de medicamentos
├── utils/
│   ├── theme.dart                   # Tema accesible
│   └── constants.dart               # Constantes globales
└── widgets/
    ├── medicine_card.dart           # Tarjeta de medicamento
    └── custom_button.dart           # Botón personalizado
```

## 🎯 Funcionalidades Implementadas

### 🔐 Autenticación
- **Inicio de sesión con Google**: Botón con logo de Google, obtiene automáticamente nombre y correo
- **Registro e inicio de sesión con Email/Contraseña**: Validación completa de formularios
- **Gestión de sesión**: Persistencia de usuario autenticado
- **Sincronización automática**: Descarga de datos del usuario al iniciar sesión

### 🏠 Pantalla Principal (Home)
- Resumen con estadísticas de medicamentos (total, por vencer)
- Lista de medicamentos próximos a vencer (30 días)
- Navegación inferior con 6 secciones: Inicio, Inventario, Tratamientos, Recordatorios, Familia, Configuración
- Acceso rápido para agregar medicamentos

### 💊 Gestión de Medicamentos
- **Agregar/Editar Medicamento**:
  - Formulario completo con validación
  - Captura de foto con OCR automático (extrae nombre, fecha, cantidad)
  - Escaneo de códigos de barras con Mobile Scanner
  - Verificación de duplicados por código de barras o nombre
  - Campos: nombre, tipo (tabletas/líquido/otro), cantidad total, cantidad restante, dosis, fecha de caducidad
  - Sincronización automática con Firestore

- **Inventario**:
  - Vista completa de todos los medicamentos
  - Filtros por estado: Todos, Activos, Por vencer, Vencidos
  - Edición y eliminación de medicamentos
  - Búsqueda y ordenamiento

### 🔔 Notificaciones
- Recordatorios de toma de medicamentos
- Notificaciones push vía Firebase Cloud Messaging
- Notificaciones locales programadas
- Estado: Pendiente / Completada
- Posponer recordatorios

### 👨‍👩‍👧 Gestión Familiar
- Vinculación de familiares por correo electrónico
- Vista de medicamentos y tratamientos de familiares (solo lectura)
- Consentimiento del usuario principal requerido

### 🩸 Tratamientos Especiales
- Registro de mediciones de glucosa (mg/dL)
- Registro de presión arterial (mmHg)
- Registro de peso (kg)
- Historial de tratamientos
- Gráficos de evolución (en desarrollo)

### ⚙️ Configuración y Accesibilidad
- **Opciones de cuenta**: Ver y editar perfil
- **Notificaciones**: Activar/desactivar recordatorios
- **Accesibilidad**:
  - Lectura por voz (Text-to-Speech)
  - Confirmación por doble toque
  - Texto grande
  - Alto contraste
- **Cerrar sesión**

### 🎨 Diseño Accesible
- Fuentes grandes (mínimo 16px)
- Botones amplios (altura mínima 56px)
- Alto contraste de colores
- Iconos grandes y claros
- Navegación simple e intuitiva
- Texto legible en español

## 🌐 Sincronización y Almacenamiento

### Sincronización Bidireccional
- **Al iniciar sesión**: Descarga todos los datos de Firestore y guarda localmente
- **Al agregar/editar**: Se actualiza en Firestore y localmente
- **Modo offline**: Los cambios se guardan localmente y se sincronizan al reconectar
- **Resolución de conflictos**: Firestore tiene prioridad sobre datos locales

### Base de Datos Local (SQLite)
- Tablas: `medicines`, `treatments`, `notifications`
- Índices para búsquedas rápidas
- Migración automática de esquema

### Firestore
- Colecciones: `users`, `medicines`, `treatments`, `notifications`
- Reglas de seguridad configuradas
- Sincronización en tiempo real

## 📋 Arquitectura de Datos

### Modelo de Usuario (`users`)
- `uid`: ID único de Firebase Auth
- `name`: Nombre completo
- `email`: Correo electrónico
- `age`: Edad (opcional)
- `linked_family`: Array de UIDs de familiares vinculados
- `created_at`: Fecha de creación

### Modelo de Medicamento (`medicines`)
- `user_id`: UID del usuario propietario
- `name`: Nombre del medicamento
- `type`: Tipo (tabletas, líquido, otro)
- `total_quantity`: Cantidad total
- `remaining_quantity`: Cantidad restante
- `dosage`: Dosis (ej: "1 tableta cada 8h")
- `expiration_date`: Fecha de caducidad
- `photo_url`: URL de imagen en Firebase Storage
- `barcode`: Código de barras escaneado
- `created_at`: Fecha de creación

### Modelo de Tratamiento (`treatments`)
- `user_id`: UID del usuario
- `type`: Tipo (diabetes, presión, otro)
- `measurement_value`: Valor de la medición
- `measurement_unit`: Unidad (mg/dL, mmHg, kg)
- `timestamp`: Fecha y hora de la medición

### Modelo de Notificación (`notifications`)
- `user_id`: UID del usuario
- `medicine_id`: Referencia al medicamento (opcional)
- `time`: Hora de la notificación
- `message`: Mensaje del recordatorio
- `status`: Estado (pending, done)

## 🔧 Configuración Adicional

### Android
- Core library desugaring habilitado para `flutter_local_notifications`
- Permisos de cámara configurados
- Google Services configurado

### iOS
- URL Scheme configurado para Google Sign In
- Permisos de cámara y galería configurados
- GoogleService-Info.plist en ubicación correcta

### Web
- Configuración de Firebase para Web
- Compatibilidad con todas las funcionalidades (excepto OCR y Barcode en Web)

## 📝 Notas de Desarrollo

- Todos los archivos incluyen el comentario: `// BioSafe - archivo generado con IA asistida - revisión: Pablo`
- El código está completamente comentado en español
- Compatible con Flutter 3.9.2+
- Diseñado para ser accesible para adultos mayores

## 🐛 Solución de Problemas

### Error de autenticación
- Verifica que Google Sign In esté habilitado en Firebase Console
- Confirma que los archivos de configuración estén en su lugar
- Revisa los SHA-1 fingerprints (Android)

### Error de sincronización
- Verifica la conexión a internet
- Revisa las reglas de seguridad de Firestore
- Verifica los permisos de la aplicación

### Error de OCR/Barcode
- Verifica los permisos de cámara
- Asegúrate de estar en un dispositivo físico (no funciona en emulador para algunas funciones)

## 👤 Desarrollador

**Pablo**  
Estudiante de Ingeniería en Sistemas Computacionales  
Universidad Autónoma de Aguascalientes  
Proyecto para la materia de Emprendedores (9no semestre)

## 📄 Licencia

Este proyecto es parte de un proyecto académico.

---

**Versión**: 1.0.0  
**Última actualización**: 2025  
**Estado**: ✅ Funcional y en producción
