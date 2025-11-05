// BioSafe - archivo generado con IA asistida - revisión: Pablo

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'firestore_service.dart';
import '../models/medicine_model.dart';

/// Servicio para escaneo de códigos de barras
class BarcodeService {
  final FirestoreService _firestoreService = FirestoreService();

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

  /// Buscar medicamento por código de barras en Firestore
  /// 
  /// Busca en los medicamentos del usuario actual
  Future<MedicineModel?> lookupMedicineByBarcode(
    String userId,
    String barcode,
  ) async {
    try {
      return await _firestoreService.findMedicineByBarcode(userId, barcode);
    } catch (e) {
      throw Exception('Error al buscar medicamento por código: $e');
    }
  }

  /// Verificar si un medicamento ya existe por código de barras
  Future<bool> medicineExists(String userId, String barcode) async {
    try {
      final medicine = await lookupMedicineByBarcode(userId, barcode);
      return medicine != null;
    } catch (e) {
      return false;
    }
  }
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

  bool _isProcessing = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Escanear Código de Barras',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on, size: 28),
            onPressed: () => controller.toggleTorch(),
            tooltip: 'Activar/Desactivar flash',
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios, size: 28),
            onPressed: () => controller.switchCamera(),
            tooltip: 'Cambiar cámara',
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              if (_isProcessing) return;

              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final barcode = barcodes.first;
                if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
                  setState(() => _isProcessing = true);
                  
                  // Esperar un momento para evitar múltiples escaneos
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (mounted) {
                      Navigator.pop(context, barcode.rawValue);
                    }
                  });
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
                border: Border.all(color: Colors.white, width: 3),
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
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          // Indicador de procesamiento
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}



