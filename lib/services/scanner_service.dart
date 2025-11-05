// BioSafe - archivo generado con IA asistida - revisión: Pablo

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Servicio para escanear códigos de barras usando mobile_scanner
class ScannerService {
  /// Muestra el escáner y retorna el código escaneado
  /// 
  /// Retorna el código escaneado o null si se cancela
  Future<String?> showBarcodeScanner(BuildContext context) async {
    return await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const BarcodeScannerScreen(),
      ),
    );
  }

  /// Simula la búsqueda de un medicamento por código de barras
  /// 
  /// En un entorno real, esto consultaría una API o base de datos
  Future<ScannedMedicineData?> lookupMedicine(String barcode) async {
    // Simulación: retorna datos ficticios basados en el código
    // En producción, esto consultaría una API externa (como OpenFDA, etc.)
    
    await Future.delayed(const Duration(seconds: 1)); // Simular delay de red
    
    // Simulación de base de datos de códigos
    final mockDatabase = {
      '7501059300076': ScannedMedicineData(
        name: 'Paracetamol 500mg',
        description: 'Analgésico y antipirético',
        manufacturer: 'Laboratorios Genéricos',
      ),
      '7501059300120': ScannedMedicineData(
        name: 'Ibuprofeno 400mg',
        description: 'Antiinflamatorio no esteroideo',
        manufacturer: 'Farmacia S.A.',
      ),
      '1234567890': ScannedMedicineData(
        name: 'Aspirina 100mg',
        description: 'Analgésico y antiagregante plaquetario',
        manufacturer: 'Farmacéutica Internacional',
      ),
    };

    return mockDatabase[barcode] ?? ScannedMedicineData(
      name: 'Medicamento no encontrado',
      description: 'Información no disponible para el código: $barcode',
      manufacturer: 'Desconocido',
    );
  }
}

/// Clase para almacenar datos de medicamento escaneado
class ScannedMedicineData {
  final String name;
  final String? description;
  final String? manufacturer;

  ScannedMedicineData({
    required this.name,
    this.description,
    this.manufacturer,
  });
}

/// Pantalla de escaneo de códigos de barras
class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear Código'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final barcode = barcodes.first;
                if (barcode.rawValue != null) {
                  Navigator.pop(context, barcode.rawValue);
                }
              }
            },
          ),
          // Overlay con guía de escaneo
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // Indicador de instrucciones
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Coloca el código de barras dentro del marco',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}