// BioSafe - archivo creado con IA asistida - revisión: Pablo

import 'package:flutter/material.dart';

/// Tema accesible para adultos mayores
class BioSafeTheme {
  // Colores principales
  static const Color primaryColor = Color(0xFF2E7D8F); // Teal oscuro
  static const Color secondaryColor = Color(0xFF4A90A4); // Teal medio
  static const Color accentColor = Color(0xFFD32F2F); // Rojo para alertas
  static const Color successColor = Color(0xFF388E3C); // Verde éxito
  static const Color warningColor = Color(0xFFF57C00); // Naranja advertencia
  static const Color backgroundColor = Color(0xFFF5F5F5); // Gris claro
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF212121); // Negro suave
  static const Color textSecondary = Color(0xFF757575); // Gris oscuro

  // Tamaños de fuente aumentados para accesibilidad
  static const double fontSizeSmall = 16.0;
  static const double fontSizeMedium = 20.0;
  static const double fontSizeLarge = 24.0;
  static const double fontSizeXLarge = 28.0;
  
  // Espaciado aumentado
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;

  // Altura mínima de botones para facilitar la interacción
  static const double buttonMinHeight = 56.0;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        error: accentColor,
        surface: cardColor,
        background: backgroundColor,
      ),
      
      // Tipografía aumentada
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: fontSizeXLarge, fontWeight: FontWeight.bold, color: textPrimary),
        displayMedium: TextStyle(fontSize: fontSizeLarge, fontWeight: FontWeight.bold, color: textPrimary),
        displaySmall: TextStyle(fontSize: fontSizeLarge, fontWeight: FontWeight.w600, color: textPrimary),
        headlineMedium: TextStyle(fontSize: fontSizeLarge, fontWeight: FontWeight.w600, color: textPrimary),
        headlineSmall: TextStyle(fontSize: fontSizeMedium, fontWeight: FontWeight.w600, color: textPrimary),
        titleLarge: TextStyle(fontSize: fontSizeMedium, fontWeight: FontWeight.w500, color: textPrimary),
        titleMedium: TextStyle(fontSize: fontSizeMedium, color: textPrimary),
        titleSmall: TextStyle(fontSize: fontSizeSmall, fontWeight: FontWeight.w500, color: textPrimary),
        bodyLarge: TextStyle(fontSize: fontSizeSmall, color: textPrimary),
        bodyMedium: TextStyle(fontSize: fontSizeSmall, color: textSecondary),
        bodySmall: TextStyle(fontSize: 14.0, color: textSecondary),
        labelLarge: TextStyle(fontSize: fontSizeSmall, fontWeight: FontWeight.w500, color: textPrimary),
      ),
      
      // Botones con altura mínima aumentada
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, buttonMinHeight),
          textStyle: const TextStyle(fontSize: fontSizeSmall, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: spacingMedium, vertical: spacingMedium),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: cardColor,
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: textSecondary, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: textSecondary, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: spacingMedium, vertical: spacingMedium),
        hintStyle: const TextStyle(fontSize: fontSizeSmall),
      ),
      
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: fontSizeXLarge,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

