// BioSafe - archivo generado con IA asistida - revisión: Pablo

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/medicine_model.dart';
import '../providers/medicine_provider.dart';
import '../providers/auth_provider.dart';
import '../services/ocr_service.dart';
import '../services/barcode_service.dart';
import '../utils/theme.dart';

/// Pantalla para agregar o editar un medicamento
class AddMedicineScreen extends StatefulWidget {
  final MedicineModel? medicine;

  const AddMedicineScreen({super.key, this.medicine});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _totalQuantityController = TextEditingController(text: '1');
  final _remainingQuantityController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final OCRService _ocrService = OCRService();
  final BarcodeService _barcodeService = BarcodeService();
  final FlutterTts _tts = FlutterTts();
  
  File? _imageFile;
  bool _isLoading = false;
  bool _isProcessingOCR = false;
  MedicineType _selectedType = MedicineType.tabletas;
  DateTime _expirationDate = DateTime.now().add(const Duration(days: 365));
  String? _barcode;

  @override
  void initState() {
    super.initState();
    if (widget.medicine != null) {
      _nameController.text = widget.medicine!.name;
      _dosageController.text = widget.medicine!.dosage;
      _totalQuantityController.text = widget.medicine!.totalQuantity.toString();
      _remainingQuantityController.text = widget.medicine!.remainingQuantity?.toString() ?? '';
      _selectedType = widget.medicine!.type;
      _expirationDate = widget.medicine!.expirationDate;
      _barcode = widget.medicine!.barcode;
    }
    _initTTS();
  }

  Future<void> _initTTS() async {
    await _tts.setLanguage("es-ES");
    await _tts.setSpeechRate(0.5);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _totalQuantityController.dispose();
    _remainingQuantityController.dispose();
    _tts.stop();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
      
      // Procesar con OCR automáticamente
      await _processOCR();
    }
  }

  Future<void> _processOCR() async {
    if (_imageFile == null) return;
    
    setState(() => _isProcessingOCR = true);
    
    try {
      final text = await _ocrService.recognizeText(_imageFile!);
      final extracted = await _ocrService.extractMedicineData(text);
      
      // Llenar formulario con datos extraídos
      setState(() {
        _nameController.text = extracted.name.isNotEmpty 
            ? extracted.name 
            : _nameController.text;
        
        _expirationDate = extracted.expiryDate ?? _expirationDate;
        
        _totalQuantityController.text = extracted.quantity > 0
            ? extracted.quantity.toString()
            : _totalQuantityController.text;
        
        _isProcessingOCR = false;
      });
      
      // Leer en voz alta
      _speak('Datos extraídos. Nombre: ${_nameController.text}');
          
    } catch (e) {
      setState(() => _isProcessingOCR = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error en OCR: $e')),
        );
      }
    }
  }

  Future<void> _scanBarcode() async {
    setState(() => _isLoading = true);
    
    try {
      final barcode = await _barcodeService.showBarcodeScanner(context);
      
      if (barcode != null) {
        setState(() {
          _barcode = barcode;
          _isLoading = false;
        });
        
        // Verificar duplicado
        final medicineProvider = Provider.of<MedicineProvider>(context, listen: false);
        final isDuplicate = await medicineProvider.isDuplicateBarcode(barcode);
        
        if (isDuplicate && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Este medicamento ya está registrado'),
              backgroundColor: BioSafeTheme.warningColor,
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Código escaneado: $barcode')),
          );
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expirationDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      locale: const Locale('es', 'ES'),
      helpText: 'Fecha de caducidad',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );
    
    if (picked != null && picked != _expirationDate) {
      setState(() => _expirationDate = picked);
      _speak('Fecha seleccionada: ${_expirationDate.day}/${_expirationDate.month}/${_expirationDate.year}');
    }
  }

  Future<void> _speak(String text) async {
    await _tts.speak(text);
  }

  Future<void> _saveMedicine() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final medicineProvider = Provider.of<MedicineProvider>(context, listen: false);
      final userId = authProvider.currentUser?.uid;
      
      if (userId == null) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: Usuario no autenticado')),
          );
        }
        return;
      }

      final medicine = MedicineModel(
        id: widget.medicine?.id,
        userId: userId,
        name: _nameController.text.trim(),
        type: _selectedType,
        totalQuantity: int.parse(_totalQuantityController.text),
        remainingQuantity: _remainingQuantityController.text.isNotEmpty
            ? int.tryParse(_remainingQuantityController.text)
            : int.parse(_totalQuantityController.text),
        dosage: _dosageController.text.trim(),
        expirationDate: _expirationDate,
        barcode: _barcode,
        createdAt: widget.medicine?.createdAt ?? DateTime.now(),
      );

      bool success;
      if (widget.medicine == null) {
        success = await medicineProvider.addMedicine(medicine);
      } else {
        success = await medicineProvider.updateMedicine(medicine);
      }
      
      setState(() => _isLoading = false);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.medicine == null 
                ? 'Medicamento agregado exitosamente'
                : 'Medicamento actualizado'),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.medicine == null ? 'Agregar Medicamento' : 'Editar Medicamento'),
        backgroundColor: BioSafeTheme.primaryColor,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Imagen o botón para tomar foto
            if (_imageFile != null)
              Container(
                height: 200,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: BioSafeTheme.primaryColor, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_imageFile!, fit: BoxFit.cover),
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.camera_alt, size: 28),
                label: const Text('Tomar Foto', style: TextStyle(fontSize: BioSafeTheme.fontSizeSmall)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: BioSafeTheme.secondaryColor,
                  minimumSize: const Size(double.infinity, BioSafeTheme.buttonMinHeight),
                ),
              ),
            
            const SizedBox(height: 12),
            
            // Botón para escanear código de barras
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _scanBarcode,
              icon: const Icon(Icons.qr_code_scanner, size: 28),
              label: const Text('Escanear Código', style: TextStyle(fontSize: BioSafeTheme.fontSizeSmall)),
              style: ElevatedButton.styleFrom(
                backgroundColor: BioSafeTheme.primaryColor.withOpacity(0.7),
                minimumSize: const Size(double.infinity, BioSafeTheme.buttonMinHeight),
              ),
            ),
            
            if (_isProcessingOCR)
              const Padding(
                padding: EdgeInsets.all(16),
                child: LinearProgressIndicator(),
              ),
            
            const SizedBox(height: 16),
            
            // Nombre del medicamento
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Medicamento',
                hintText: 'Ej: Paracetamol 500mg',
                prefixIcon: Icon(Icons.medication_liquid),
              ),
              style: const TextStyle(fontSize: BioSafeTheme.fontSizeSmall),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre es requerido';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Tipo de medicamento
            DropdownButtonFormField<MedicineType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Tipo',
                prefixIcon: Icon(Icons.category),
              ),
              items: MedicineType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedType = value);
                }
              },
            ),
            
            const SizedBox(height: 16),
            
            // Dosis
            TextFormField(
              controller: _dosageController,
              decoration: const InputDecoration(
                labelText: 'Dosis',
                hintText: 'Ej: 1 tableta cada 8 horas',
                prefixIcon: Icon(Icons.schedule),
              ),
              style: const TextStyle(fontSize: BioSafeTheme.fontSizeSmall),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La dosis es requerida';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Cantidad total
            TextFormField(
              controller: _totalQuantityController,
              decoration: const InputDecoration(
                labelText: 'Cantidad Total',
                hintText: 'Número de unidades',
                prefixIcon: Icon(Icons.inventory_2),
              ),
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: BioSafeTheme.fontSizeSmall),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La cantidad es requerida';
                }
                final quantity = int.tryParse(value);
                if (quantity == null || quantity < 1) {
                  return 'Ingrese un número válido mayor a 0';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Cantidad restante
            TextFormField(
              controller: _remainingQuantityController,
              decoration: const InputDecoration(
                labelText: 'Cantidad Restante (opcional)',
                hintText: 'Dejar vacío para usar la cantidad total',
                prefixIcon: Icon(Icons.assignment),
              ),
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: BioSafeTheme.fontSizeSmall),
            ),
            
            const SizedBox(height: 16),
            
            // Fecha de caducidad
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Fecha de Caducidad',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  '${_expirationDate.day}/${_expirationDate.month}/${_expirationDate.year}',
                  style: const TextStyle(
                    fontSize: BioSafeTheme.fontSizeSmall,
                    color: BioSafeTheme.textPrimary,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Botón de guardar
            ElevatedButton(
              onPressed: _isLoading ? null : _saveMedicine,
              style: ElevatedButton.styleFrom(
                backgroundColor: BioSafeTheme.primaryColor,
                minimumSize: const Size(double.infinity, BioSafeTheme.buttonMinHeight),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      widget.medicine == null ? 'Guardar Medicamento' : 'Actualizar',
                      style: const TextStyle(
                        fontSize: BioSafeTheme.fontSizeSmall,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
