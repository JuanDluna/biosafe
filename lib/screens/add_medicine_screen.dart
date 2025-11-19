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
  final _descriptionController = TextEditingController();
  final _dosageController = TextEditingController();
  final _totalQuantityController = TextEditingController(text: '1');
  final _remainingQuantityController = TextEditingController();
  
  // Controllers para dosis temporizada
  final _dosageAmountController = TextEditingController();
  final _dosageIntervalController = TextEditingController();
  final _dosageDurationController = TextEditingController();
  final _dateController = TextEditingController();
  
  final ImagePicker _picker = ImagePicker();
  final OCRService _ocrService = OCRService();
  final BarcodeService _barcodeService = BarcodeService();
  final FlutterTts _tts = FlutterTts();
  
  File? _imageFile;
  bool _isLoading = false;
  bool _isProcessingOCR = false;
  bool _showTimedDosage = false; // Mostrar formulario de dosis temporizada
  MedicineType _selectedType = MedicineType.tabletas;
  DateTime _expirationDate = DateTime.now().add(const Duration(days: 365));
  String? _barcode;

  @override
  void initState() {
    super.initState();
    if (widget.medicine != null) {
      _nameController.text = widget.medicine!.name;
      _descriptionController.text = widget.medicine!.description;
      _dosageController.text = widget.medicine!.dosage;
      _totalQuantityController.text = widget.medicine!.totalQuantity.toString();
      _remainingQuantityController.text = widget.medicine!.remainingQuantity?.toString() ?? '';
      _selectedType = widget.medicine!.type;
      _expirationDate = widget.medicine!.expirationDate;
      _barcode = widget.medicine!.barcode;
      
      // Si tiene dosis temporizada, mostrar el formulario
      if (widget.medicine!.dosageAmount != null || 
          widget.medicine!.dosageIntervalHours != null ||
          widget.medicine!.dosageDurationDays != null) {
        _showTimedDosage = true;
        _dosageAmountController.text = widget.medicine!.dosageAmount ?? '';
        _dosageIntervalController.text = widget.medicine!.dosageIntervalHours?.toString() ?? '';
        _dosageDurationController.text = widget.medicine!.dosageDurationDays?.toString() ?? '';
      }
    }
    
    // Agregar listeners para actualizar vista previa
    _dosageAmountController.addListener(() => setState(() {}));
    _dosageIntervalController.addListener(() => setState(() {}));
    _dosageDurationController.addListener(() => setState(() {}));
    
    // Inicializar el texto de la fecha
    _updateDateText();
    
    _initTTS();
  }
  
  void _updateDateText() {
    _dateController.text = '${_expirationDate.day.toString().padLeft(2, '0')}/${_expirationDate.month.toString().padLeft(2, '0')}/${_expirationDate.year}';
  }

  Future<void> _initTTS() async {
    await _tts.setLanguage("es-ES");
    await _tts.setSpeechRate(0.5);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _dosageController.dispose();
    _totalQuantityController.dispose();
    _remainingQuantityController.dispose();
    _dosageAmountController.dispose();
    _dosageIntervalController.dispose();
    _dosageDurationController.dispose();
    _dateController.dispose();
    _tts.stop();
    super.dispose();
  }

  /// Generar texto de dosis basado en los campos temporizados
  String _generateDosageText() {
    if (!_showTimedDosage) {
      return _dosageController.text.trim();
    }
    
    final amount = _dosageAmountController.text.trim();
    final interval = _dosageIntervalController.text.trim();
    final duration = _dosageDurationController.text.trim();
    
    if (amount.isEmpty) {
      return _dosageController.text.trim();
    }
    
    String dosageText = amount;
    
    if (interval.isNotEmpty) {
      final intervalHours = int.tryParse(interval);
      if (intervalHours != null && intervalHours > 0) {
        dosageText += ' cada $intervalHours ${intervalHours == 1 ? 'hora' : 'horas'}';
      }
    }
    
    if (duration.isNotEmpty) {
      final durationDays = int.tryParse(duration);
      if (durationDays != null && durationDays > 0) {
        dosageText += ' durante $durationDays ${durationDays == 1 ? 'día' : 'días'}';
      }
    }
    
    return dosageText;
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
        if (mounted) {
          final medicineProvider = Provider.of<MedicineProvider>(context, listen: false);
          final isDuplicate = await medicineProvider.isDuplicateBarcode(barcode);
          
          if (!mounted) return;
          
          if (isDuplicate) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Este medicamento ya está registrado'),
                backgroundColor: BioSafeTheme.warningColor,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Código escaneado: $barcode')),
            );
          }
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
    // Cerrar el teclado si está abierto
    FocusScope.of(context).unfocus();
    
    // Esperar un momento para que el teclado se cierre completamente
    await Future.delayed(const Duration(milliseconds: 200));
    
    if (!mounted) return;
    
    // Usar showDatePicker con mejor manejo
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expirationDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      locale: const Locale('es', 'ES'),
      helpText: 'Seleccionar Fecha de Caducidad',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: BioSafeTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: BioSafeTheme.textPrimary,
              surface: Colors.white,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: BioSafeTheme.primaryColor,
                textStyle: const TextStyle(
                  fontSize: BioSafeTheme.fontSizeSmall,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (!mounted) return;
    
    if (picked != null) {
      setState(() {
        _expirationDate = picked;
        _updateDateText();
      });
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

      // Generar texto de dosis
      String finalDosage = '';
      
      if (_showTimedDosage) {
        // Si está habilitada la dosis temporizada, generar el texto
        final dosageText = _generateDosageText();
        finalDosage = dosageText.isNotEmpty ? dosageText : 'Sin especificar';
      } else {
        // Si no está habilitada la dosis temporizada, usar valor por defecto
        finalDosage = 'Sin especificar';
      }

      final medicine = MedicineModel(
        id: widget.medicine?.id,
        userId: userId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _selectedType,
        totalQuantity: int.parse(_totalQuantityController.text),
        remainingQuantity: _remainingQuantityController.text.isNotEmpty
            ? int.tryParse(_remainingQuantityController.text)
            : int.parse(_totalQuantityController.text),
        dosage: finalDosage,
        dosageAmount: _showTimedDosage && _dosageAmountController.text.trim().isNotEmpty
            ? _dosageAmountController.text.trim()
            : null,
        dosageIntervalHours: _showTimedDosage && _dosageIntervalController.text.trim().isNotEmpty
            ? int.tryParse(_dosageIntervalController.text.trim())
            : null,
        dosageDurationDays: _showTimedDosage && _dosageDurationController.text.trim().isNotEmpty
            ? int.tryParse(_dosageDurationController.text.trim())
            : null,
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
            
            // Nombre del medicamento (REQUERIDO)
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Medicamento *',
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
            
            // Descripción (REQUERIDA)
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción *',
                hintText: 'Descripción del medicamento, uso, indicaciones...',
                prefixIcon: Icon(Icons.description),
              ),
              style: const TextStyle(fontSize: BioSafeTheme.fontSizeSmall),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La descripción es requerida';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Tipo de medicamento
            DropdownButtonFormField<MedicineType>(
              initialValue: _selectedType,
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
            
            // Cantidad total
            TextFormField(
              controller: _totalQuantityController,
              decoration: InputDecoration(
                labelText: _selectedType == MedicineType.liquido 
                    ? 'Cantidad Total (ml)' 
                    : 'Cantidad Total',
                hintText: _selectedType == MedicineType.liquido 
                    ? 'Ej: 500 ml' 
                    : 'Número de unidades',
                prefixIcon: const Icon(Icons.inventory_2),
                suffixText: _selectedType == MedicineType.liquido ? 'ml' : null,
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
              decoration: InputDecoration(
                labelText: _selectedType == MedicineType.liquido 
                    ? 'Cantidad Restante (ml) (opcional)' 
                    : 'Cantidad Restante (opcional)',
                hintText: _selectedType == MedicineType.liquido 
                    ? 'Dejar vacío para usar la cantidad total' 
                    : 'Dejar vacío para usar la cantidad total',
                prefixIcon: const Icon(Icons.assignment),
                suffixText: _selectedType == MedicineType.liquido ? 'ml' : null,
              ),
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: BioSafeTheme.fontSizeSmall),
            ),
            
            const SizedBox(height: 16),
            
            // Fecha de caducidad (REQUERIDA)
            InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: BioSafeTheme.textSecondary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fecha de Caducidad *',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_expirationDate.day.toString().padLeft(2, '0')}/${_expirationDate.month.toString().padLeft(2, '0')}/${_expirationDate.year}',
                            style: const TextStyle(
                              fontSize: BioSafeTheme.fontSizeSmall,
                              color: BioSafeTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_drop_down,
                      color: BioSafeTheme.textSecondary,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
            // Validación de fecha (mostrar error si es necesario)
            if (_expirationDate.isBefore(DateTime.now().subtract(const Duration(days: 1))))
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 12),
                child: Text(
                  'La fecha no puede ser anterior a hoy',
                  style: TextStyle(
                    fontSize: 12,
                    color: BioSafeTheme.accentColor,
                  ),
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Sección de Dosis
            Card(
              color: BioSafeTheme.primaryColor.withOpacity(0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.schedule, color: BioSafeTheme.primaryColor, size: 28),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Dosis',
                            style: TextStyle(
                              fontSize: BioSafeTheme.fontSizeMedium,
                              fontWeight: FontWeight.bold,
                              color: BioSafeTheme.primaryColor,
                            ),
                          ),
                        ),
                          Switch(
                          value: _showTimedDosage,
                          onChanged: (value) {
                            setState(() {
                              _showTimedDosage = value;
                              if (!value) {
                                // Limpiar campos de dosis temporizada
                                _dosageAmountController.clear();
                                _dosageIntervalController.clear();
                                _dosageDurationController.clear();
                              }
                            });
                          },
                          activeThumbColor: BioSafeTheme.primaryColor,
                        ),
                      ],
                    ),
                  ),
                  
                  if (_showTimedDosage) ...[
                    // Dosis temporizada (formulario estructurado)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Dosis Temporizada (Opcional)',
                            style: TextStyle(
                              fontSize: BioSafeTheme.fontSizeSmall,
                              fontWeight: FontWeight.bold,
                              color: BioSafeTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _dosageAmountController,
                            decoration: InputDecoration(
                              labelText: _selectedType == MedicineType.liquido 
                                  ? 'Cantidad de dosis (ml)' 
                                  : 'Cantidad de dosis',
                              hintText: _selectedType == MedicineType.liquido 
                                  ? 'Ej: 5ml, 10ml' 
                                  : 'Ej: 1 tableta, 2 cápsulas',
                              prefixIcon: const Icon(Icons.medication),
                              suffixText: _selectedType == MedicineType.liquido ? 'ml' : null,
                            ),
                            style: const TextStyle(fontSize: BioSafeTheme.fontSizeSmall),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _dosageIntervalController,
                                  decoration: const InputDecoration(
                                    labelText: 'Cada (horas)',
                                    hintText: '8',
                                    prefixIcon: Icon(Icons.access_time),
                                  ),
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(fontSize: BioSafeTheme.fontSizeSmall),
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      final hours = int.tryParse(value);
                                      if (hours == null || hours < 1) {
                                        return 'Mínimo 1 hora';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _dosageDurationController,
                                  decoration: const InputDecoration(
                                    labelText: 'Duración (días)',
                                    hintText: '7',
                                    prefixIcon: Icon(Icons.calendar_today),
                                  ),
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(fontSize: BioSafeTheme.fontSizeSmall),
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      final days = int.tryParse(value);
                                      if (days == null || days < 1) {
                                        return 'Mínimo 1 día';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Vista previa de la dosis generada
                          if (_dosageAmountController.text.isNotEmpty ||
                              _dosageIntervalController.text.isNotEmpty ||
                              _dosageDurationController.text.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: BioSafeTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: BioSafeTheme.primaryColor.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline, 
                                      color: BioSafeTheme.primaryColor, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Vista previa: ${_generateDosageText()}',
                                      style: const TextStyle(
                                        fontSize: BioSafeTheme.fontSizeSmall,
                                        color: BioSafeTheme.primaryColor,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
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
