// BioSafe - archivo creado con IA asistida - revisión: Pablo

/// Constantes globales de la aplicación
class AppConstants {
  // Nombres de rutas
  static const String routeHome = '/';
  static const String routeInventory = '/inventory';
  static const String routeAddMedicine = '/add-medicine';
  static const String routeSettings = '/settings';
  
  // Mensajes
  static const String appName = 'BioSafe';
  static const String appSubtitle = 'Control de Medicamentos';
  
  // Mensajes de usuario
  static const String emptyInventory = 'No hay medicamentos registrados';
  static const String noExpiringMedicines = 'No hay medicamentos próximos a vencer';
  static const String noExpiredMedicines = 'No hay medicamentos vencidos';
  
  // Validación
  static const int minQuantity = 1;
  static const int maxQuantity = 9999;
  
  // Expiración
  static const int daysBeforeExpiryWarning = 30;
}

