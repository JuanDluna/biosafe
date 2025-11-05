// BioSafe - archivo creado con IA asistida - revisión: Pablo

import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Servicio para reconocimiento óptico de caracteres (OCR) en medicamentos
class OCRService {
  final TextRecognizer _textRecognizer;

  OCRService() : _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  /// Procesa una imagen y extrae el texto
  Future<String> recognizeText(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
    return recognizedText.text;
  }

  /// Extrae campos estructurados del texto OCR
  Future<ExtractedMedicineData> extractMedicineData(String text) async {
    final extracted = ExtractedMedicineData();

    // 1. Buscar nombre del medicamento
    extracted.name = _extractName(text);
    
    // 2. Buscar fecha de caducidad
    extracted.expiryDate = _extractExpiryDate(text);
    
    // 3. Buscar cantidad
    extracted.quantity = _extractQuantity(text);

    return extracted;
  }

  /// Extrae el nombre del medicamento
  String _extractName(String text) {
    final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    
    if (lines.isEmpty) return '';
    
    // Buscar línea con palabras clave farmacéuticas
    for (final line in lines) {
      if (RegExp(r'\b(mg|ml|tableta|tabletas|cápsulas|suspensión|solución|jarabe|comprimido)\b', 
          caseSensitive: false).hasMatch(line)) {
        return line;
      }
    }
    
    // Si no se encuentra, devolver la primera línea
    return lines.first;
  }

  /// Extrae la fecha de caducidad
  DateTime? _extractExpiryDate(String text) {
    // Buscar patrones de fecha: dd/mm/yyyy, mm/yyyy, yyyy-mm-dd, etc.
    final dateRegex = RegExp(
      r'(\d{1,2}[/\-\.]\d{1,2}[/\-\.]\d{2,4})|(\d{1,2}[/\-\.]\d{4})|(\bEXP[:\s]*\d{2}[/\-\.]\d{2}[/\-\.]?\d{2,4}\b)',
      caseSensitive: false
    );
    
    final matches = dateRegex.allMatches(text);
    if (matches.isEmpty) return null;
    
    String foundDate = matches.first.group(0) ?? '';
    // Limpiar prefijos comunes
    foundDate = foundDate.replaceAll(RegExp(r'EXP[:\s]*', caseSensitive: false), '');
    
    // Normalizar la fecha
    return _normalizeDate(foundDate);
  }

  /// Normaliza diferentes formatos de fecha
  DateTime? _normalizeDate(String dateStr) {
    try {
      final cleaned = dateStr.replaceAll('.', '/').replaceAll('-', '/');
      final parts = cleaned.split('/');
      
      if (parts.length == 3) {
        final day = int.tryParse(parts[0]) ?? 1;
        final month = int.tryParse(parts[1]) ?? 1;
        final year = int.tryParse(parts[2]) ?? DateTime.now().year;
        return DateTime(year < 100 ? 2000 + year : year, month, day);
      } else if (parts.length == 2) {
        final month = int.tryParse(parts[0]) ?? 1;
        final year = int.tryParse(parts[1]) ?? DateTime.now().year;
        return DateTime(year < 100 ? 2000 + year : year, month, 1);
      }
    } catch (e) {
      // Si falla, retornar null
    }
    return null;
  }

  /// Extrae la cantidad de medicamentos
  int _extractQuantity(String text) {
    // Buscar números seguidos de palabras como "tabletas", "cápsulas", etc.
    final quantityRegex = RegExp(r'\b(\d+)\s*(tabletas?|cápsulas?|comprimidos?)\b', caseSensitive: false);
    final match = quantityRegex.firstMatch(text);
    
    if (match != null) {
      return int.tryParse(match.group(1) ?? '') ?? 1;
    }
    
    return 1; // Cantidad por defecto
  }

  /// Liberar recursos
  void dispose() {
    _textRecognizer.close();
  }
}

/// Clase para almacenar datos extraídos del OCR
class ExtractedMedicineData {
  String name = '';
  DateTime? expiryDate;
  int quantity = 1;
}

