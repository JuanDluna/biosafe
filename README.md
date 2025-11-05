# 🏥 BioSafe - Control de Medicamentos

**BioSafe** es una aplicación móvil desarrollada en Flutter enfocada en adultos mayores para el control y gestión de medicamentos. Incluye funcionalidades de escaneo OCR con IA, lectura de códigos de barras, y un sistema de recordatorios accesible.

## 📱 Características Principales

- ✅ **Gestión de Inventario**: Añade, edita y elimina medicamentos
- 📸 **Escaneo OCR**: Captura y reconoce texto de medicamentos usando Google ML Kit
- 🔍 **Lectura de Códigos**: Escanea códigos de barras para búsqueda automática
- ⚠️ **Alertas de Caducidad**: Avisos para medicamentos próximos a vencer o vencidos
- 🔊 **Text-to-Speech**: Lectura de voz para mejorar accesibilidad
- 💾 **Almacenamiento Local**: Base de datos SQLite para funcionar offline
- 🎨 **Diseño Accesible**: UI optimizada para adultos mayores con fuentes grandes y alto contraste

## 🛠️ Tecnologías Utilizadas

- **Flutter** - Framework multiplataforma
- **Dart** - Lenguaje de programación
- **SQLite** (sqflite) - Base de datos local
- **Google ML Kit** - Reconocimiento óptico de caracteres (OCR)
- **Flutter TTS** - Text-to-Speech para accesibilidad
- **Image Picker** - Captura de imágenes
- **Flutter Barcode Scanner** - Escaneo de códigos de barras

## 🚀 Instalación y Ejecución

### Requisitos Previos

- Flutter SDK (versión 3.9.2 o superior)
- Dart SDK
- Android Studio / Visual Studio Code
- Un dispositivo Android físico o emulador

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

3. **Ejecutar la aplicación**
```bash
flutter run
```

## 📂 Estructura del Proyecto

```
lib/
├── main.dart                   # Punto de entrada
├── models/
│   └── medicine_model.dart     # Modelo de datos
├── screens/
│   ├── home_screen.dart        # Pantalla principal
│   ├── inventory_screen.dart   # Inventario completo
│   └── add_medicine_screen.dart# Agregar/Editar medicamento
├── services/
│   ├── database_service.dart   # Servicio de base de datos
│   ├── ocr_service.dart        # Servicio de OCR
│   └── scanner_service.dart    # Servicio de escaneo
├── utils/
│   ├── theme.dart             # Tema accesible
│   └── constants.dart         # Constantes globales
└── widgets/
    ├── medicine_card.dart     # Tarjeta de medicamento
    └── custom_button.dart     # Botón personalizado
```

## 🎯 Funcionalidades Implementadas

### Pantalla Principal (Home)
- Resumen con estadísticas de medicamentos
- Lista de medicamentos próximos a vencer
- Navegación rápida al inventario

### Pantalla de Inventario
- Vista de todos los medicamentos
- Filtros: Todos / Por vencer / Vencidos
- Opciones de edición y eliminación

### Agregar/Editar Medicamento
- Formulario completo con validación
- Captura de foto con OCR automático
- Escaneo de códigos de barras
- Selección de fecha de caducidad
- Lectura en voz alta de los datos

## 🔧 Prototipo Front-End Solo

Esta versión es un **prototipo funcional solo front-end** con:
- ✅ Base de datos local SQLite
- ✅ Simulaciones de datos (códigos de barras simulados)
- ✅ Todo funciona offline
- ✅ Sin dependencias de backend o Firebase

**Perfecto para demostraciones y pruebas en dispositivos Android.**

## 👤 Desarrollador

**Pablo**  
Estudiante de Técnico en Sistemas  
Universidad Autónoma de Aguascalientes  
Proyecto para la materia de Emprendedores (9no semestre)

## 📄 Licencia

Este proyecto es parte de un proyecto académico.

---

**Nota**: Esta es una versión de prototipo para demostración. Para producción se recomendaría integrar Firebase para sincronización en la nube.
