// BioSafe - archivo generado con IA asistida - revisión: Pablo

import 'package:flutter/material.dart';
import '../models/medicine_model.dart';
import '../services/firestore_service.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

/// Provider para gestión de medicamentos
class MedicineProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final DatabaseService _databaseService = DatabaseService();
  final NotificationService _notificationService = NotificationService();

  List<MedicineModel> _medicines = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _userId;

  List<MedicineModel> get medicines => _medicines;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Establecer usuario actual
  void setUserId(String userId) {
    _userId = userId;
  }

  /// Cargar medicamentos desde local y remoto
  Future<void> loadMedicines() async {
    if (_userId == null) return;

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Cargar desde local primero
      final localMedicines = await _databaseService.getMedicines(_userId!);
      _medicines = localMedicines;
      notifyListeners();

      // Sincronizar con Firestore
      try {
        final remoteMedicines = await _firestoreService.getMedicines(_userId!);
        
        // Sincronizar: agregar/actualizar medicamentos remotos en local
        for (final remoteMedicine in remoteMedicines) {
          final existing = await _databaseService.getMedicineByFirestoreId(remoteMedicine.id!);
          if (existing == null) {
            await _databaseService.insertMedicine(remoteMedicine);
          } else {
            await _databaseService.updateMedicine(remoteMedicine);
          }
        }

        // Actualizar lista local
        _medicines = await _databaseService.getMedicines(_userId!);
        
        // Verificar y programar alertas de vencimiento para todos los medicamentos
        try {
          await _notificationService.checkAndScheduleExpirationAlerts(
            userId: _userId!,
            medicines: _medicines,
          );
        } catch (e) {
          // Error silencioso en notificaciones
        }
      } catch (e) {
        // Si falla la sincronización, usar datos locales
        _errorMessage = 'Sin conexión. Mostrando datos locales.';
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al cargar medicamentos: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Agregar medicamento
  Future<bool> addMedicine(MedicineModel medicine) async {
    if (_userId == null) return false;

    try {
      _isLoading = true;
      notifyListeners();

      // Guardar en Firestore
      String? firestoreId;
      try {
        firestoreId = await _firestoreService.createMedicine(medicine);
        medicine = medicine.copyWith(id: firestoreId);
      } catch (e) {
        // Si falla, guardar solo localmente
        _errorMessage = 'Sin conexión. Guardado localmente.';
      }

      // Guardar localmente
      await _databaseService.insertMedicine(medicine);

      _medicines.add(medicine);
      
      // Programar notificaciones para el nuevo medicamento
      if (_userId != null) {
        try {
          // Programar recordatorios de dosis si tiene dosis temporizada
          await _notificationService.scheduleMedicineDosageReminders(
            userId: _userId!,
            medicine: medicine,
          );
          
          // Programar alerta de vencimiento
          await _notificationService.scheduleExpirationAlert(
            userId: _userId!,
            medicine: medicine,
          );
        } catch (e) {
          // Error silencioso en notificaciones
        }
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al agregar medicamento: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Actualizar medicamento
  Future<bool> updateMedicine(MedicineModel medicine) async {
    if (_userId == null || medicine.id == null) return false;

    try {
      _isLoading = true;
      notifyListeners();

      // Actualizar en Firestore
      try {
        await _firestoreService.updateMedicine(medicine);
      } catch (e) {
        // Si falla, guardar solo localmente
        _errorMessage = 'Sin conexión. Actualizado localmente.';
      }

      // Actualizar localmente
      await _databaseService.updateMedicine(medicine);

      final index = _medicines.indexWhere((m) => m.id == medicine.id);
      if (index != -1) {
        _medicines[index] = medicine;
      }
      
      // Reprogramar notificaciones para el medicamento actualizado
      if (_userId != null) {
        try {
          // Cancelar notificaciones anteriores
          if (medicine.id != null) {
            await _notificationService.cancelAllMedicineNotifications(medicine.id!);
          }
          
          // Programar nuevas notificaciones
          await _notificationService.scheduleMedicineDosageReminders(
            userId: _userId!,
            medicine: medicine,
          );
          
          await _notificationService.scheduleExpirationAlert(
            userId: _userId!,
            medicine: medicine,
          );
        } catch (e) {
          // Error silencioso en notificaciones
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al actualizar medicamento: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Eliminar medicamento
  Future<bool> deleteMedicine(String medicineId) async {
    if (_userId == null) return false;

    try {
      _isLoading = true;
      notifyListeners();

      // Eliminar en Firestore
      try {
        await _firestoreService.deleteMedicine(medicineId);
      } catch (e) {
        // Si falla, eliminar solo localmente
        _errorMessage = 'Sin conexión. Eliminado localmente.';
      }

      // Eliminar localmente
      await _databaseService.deleteMedicineByFirestoreId(medicineId);

      // Cancelar notificaciones del medicamento eliminado
      try {
        await _notificationService.cancelAllMedicineNotifications(medicineId);
      } catch (e) {
        // Error silencioso
      }

      _medicines.removeWhere((m) => m.id == medicineId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al eliminar medicamento: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Obtener medicamentos por estado
  List<MedicineModel> getMedicinesByStatus(MedicineStatus status) {
    return _medicines.where((m) => m.status == status).toList();
  }

  /// Obtener medicamentos próximos a vencer
  Future<List<MedicineModel>> getExpiringMedicines() async {
    if (_userId == null) return [];
    return await _databaseService.getExpiringMedicines(_userId!);
  }

  /// Obtener medicamentos vencidos
  Future<List<MedicineModel>> getExpiredMedicines() async {
    if (_userId == null) return [];
    return await _databaseService.getExpiredMedicines(_userId!);
  }

  /// Verificar duplicado por código de barras
  Future<bool> isDuplicateBarcode(String barcode) async {
    if (_userId == null) return false;
    try {
      final existing = await _firestoreService.findMedicineByBarcode(_userId!, barcode);
      return existing != null;
    } catch (e) {
      // Verificar en local
      return _medicines.any((m) => m.barcode == barcode);
    }
  }

  /// Verificar duplicado por nombre
  Future<bool> isDuplicateName(String name) async {
    if (_userId == null) return false;
    try {
      final existing = await _firestoreService.findMedicineByName(_userId!, name);
      return existing != null;
    } catch (e) {
      // Verificar en local
      return _medicines.any((m) => m.name.toLowerCase() == name.toLowerCase());
    }
  }

  /// Limpiar mensaje de error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}



