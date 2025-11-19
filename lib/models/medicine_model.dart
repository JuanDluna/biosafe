// BioSafe - archivo generado con IA asistida - revisión: Pablo

/// Modelo de Medicamento según esquema Firestore
class MedicineModel {
  final String? id; // ID del documento Firestore
  final String userId; // uid del usuario propietario
  final String name;
  final String description; // Descripción del medicamento
  final MedicineType type; // "tabletas", "líquido", "otro"
  final int totalQuantity; // Total de tabletas o ml
  final int? remainingQuantity; // Cantidad restante (puede ser nulo o igual a total)
  final String dosage; // Ej. "1 tableta cada 8h"
  // Campos opcionales para dosis temporizada
  final String? dosageAmount; // Ej. "1 tableta", "5ml"
  final int? dosageIntervalHours; // Cada cuántas horas (ej: 8)
  final int? dosageDurationDays; // Cuántos días (ej: 7)
  final DateTime expirationDate;
  final String? photoUrl; // URL de Firebase Storage
  final String? barcode; // Código de barras escaneado
  final DateTime createdAt;

  MedicineModel({
    this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.type,
    required this.totalQuantity,
    this.remainingQuantity,
    required this.dosage,
    this.dosageAmount,
    this.dosageIntervalHours,
    this.dosageDurationDays,
    required this.expirationDate,
    this.photoUrl,
    this.barcode,
    required this.createdAt,
  });

  /// Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'name': name,
      'description': description,
      'type': type.name,
      'total_quantity': totalQuantity,
      'remaining_quantity': remainingQuantity,
      'dosage': dosage,
      'dosage_amount': dosageAmount,
      'dosage_interval_hours': dosageIntervalHours,
      'dosage_duration_days': dosageDurationDays,
      'expiration_date': expirationDate.toIso8601String(),
      'photo_url': photoUrl,
      'barcode': barcode,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Crear desde Map de Firestore
  factory MedicineModel.fromFirestore(String id, Map<String, dynamic> map) {
    return MedicineModel(
      id: id,
      userId: map['user_id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      type: MedicineType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MedicineType.otro,
      ),
      totalQuantity: (map['total_quantity'] as num?)?.toInt() ?? 0,
      remainingQuantity: (map['remaining_quantity'] as num?)?.toInt(),
      dosage: map['dosage'] as String? ?? '',
      dosageAmount: map['dosage_amount'] as String?,
      dosageIntervalHours: (map['dosage_interval_hours'] as num?)?.toInt(),
      dosageDurationDays: (map['dosage_duration_days'] as num?)?.toInt(),
      expirationDate: map['expiration_date'] != null
          ? DateTime.parse(map['expiration_date'] as String)
          : DateTime.now(),
      photoUrl: map['photo_url'] as String?,
      barcode: map['barcode'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
    );
  }

  /// Convertir a Map para SQLite (compatibilidad local)
  Map<String, dynamic> toMap() {
    return {
      'id': id?.hashCode, // Usar hash del ID como entero para SQLite
      'firestore_id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'type': type.name,
      'total_quantity': totalQuantity,
      'remaining_quantity': remainingQuantity,
      'dosage': dosage,
      'dosage_amount': dosageAmount,
      'dosage_interval_hours': dosageIntervalHours,
      'dosage_duration_days': dosageDurationDays,
      'expiration_date': expirationDate.toIso8601String(),
      'photo_url': photoUrl,
      'barcode': barcode,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Crear desde Map de SQLite
  factory MedicineModel.fromMap(Map<String, dynamic> map) {
    return MedicineModel(
      id: map['firestore_id'] as String?,
      userId: map['user_id'] as String? ?? '',
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      type: MedicineType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MedicineType.otro,
      ),
      totalQuantity: map['total_quantity'] as int,
      remainingQuantity: map['remaining_quantity'] as int?,
      dosage: map['dosage'] as String? ?? '',
      dosageAmount: map['dosage_amount'] as String?,
      dosageIntervalHours: map['dosage_interval_hours'] as int?,
      dosageDurationDays: map['dosage_duration_days'] as int?,
      expirationDate: DateTime.parse(map['expiration_date'] as String),
      photoUrl: map['photo_url'] as String?,
      barcode: map['barcode'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Crear copia con campos modificados
  MedicineModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    MedicineType? type,
    int? totalQuantity,
    int? remainingQuantity,
    String? dosage,
    String? dosageAmount,
    int? dosageIntervalHours,
    int? dosageDurationDays,
    DateTime? expirationDate,
    String? photoUrl,
    String? barcode,
    DateTime? createdAt,
  }) {
    return MedicineModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      remainingQuantity: remainingQuantity ?? this.remainingQuantity,
      dosage: dosage ?? this.dosage,
      dosageAmount: dosageAmount ?? this.dosageAmount,
      dosageIntervalHours: dosageIntervalHours ?? this.dosageIntervalHours,
      dosageDurationDays: dosageDurationDays ?? this.dosageDurationDays,
      expirationDate: expirationDate ?? this.expirationDate,
      photoUrl: photoUrl ?? this.photoUrl,
      barcode: barcode ?? this.barcode,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Verificar si el medicamento está por vencer (30 días o menos)
  bool get isExpiringSoon {
    final daysUntilExpiry = expirationDate.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 30 && daysUntilExpiry >= 0;
  }

  /// Verificar si el medicamento está vencido
  bool get isExpired {
    return expirationDate.isBefore(DateTime.now());
  }

  /// Verificar si el medicamento está agotado
  bool get isDepleted {
    return remainingQuantity != null && remainingQuantity! <= 0;
  }

  /// Obtener estado del medicamento
  MedicineStatus get status {
    if (isDepleted) return MedicineStatus.depleted;
    if (isExpired) return MedicineStatus.expired;
    if (isExpiringSoon) return MedicineStatus.expiring;
    return MedicineStatus.active;
  }

  @override
  String toString() {
    return 'MedicineModel(id: $id, name: $name, type: ${type.name}, totalQuantity: $totalQuantity, remainingQuantity: $remainingQuantity)';
  }
}

/// Tipos de medicamento
enum MedicineType {
  tabletas,
  liquido,
  otro,
}

extension MedicineTypeExtension on MedicineType {
  String get displayName {
    switch (this) {
      case MedicineType.tabletas:
        return 'Tabletas';
      case MedicineType.liquido:
        return 'Líquido';
      case MedicineType.otro:
        return 'Otro';
    }
  }
}

/// Estado del medicamento
enum MedicineStatus {
  active,
  expiring,
  expired,
  depleted,
}

extension MedicineStatusExtension on MedicineStatus {
  String get displayName {
    switch (this) {
      case MedicineStatus.active:
        return 'Activo';
      case MedicineStatus.expiring:
        return 'Por vencer';
      case MedicineStatus.expired:
        return 'Vencido';
      case MedicineStatus.depleted:
        return 'Agotado';
    }
  }
}

