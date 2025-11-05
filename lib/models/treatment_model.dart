// BioSafe - archivo generado con IA asistida - revisión: Pablo

/// Modelo de Tratamiento según esquema Firestore
class TreatmentModel {
  final String? id; // ID del documento Firestore
  final String userId; // uid del usuario
  final TreatmentType type; // "diabetes", "presión", "otro"
  final double measurementValue;
  final String measurementUnit; // "mg/dL", "mmHg", "kg"
  final DateTime timestamp;

  TreatmentModel({
    this.id,
    required this.userId,
    required this.type,
    required this.measurementValue,
    required this.measurementUnit,
    required this.timestamp,
  });

  /// Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'type': type.name,
      'measurement_value': measurementValue,
      'measurement_unit': measurementUnit,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Crear desde Map de Firestore
  factory TreatmentModel.fromMap(String id, Map<String, dynamic> map) {
    return TreatmentModel(
      id: id,
      userId: map['user_id'] as String? ?? '',
      type: TreatmentType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TreatmentType.otro,
      ),
      measurementValue: (map['measurement_value'] as num?)?.toDouble() ?? 0.0,
      measurementUnit: map['measurement_unit'] as String? ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'] as String)
          : DateTime.now(),
    );
  }

  /// Crear copia con campos modificados
  TreatmentModel copyWith({
    String? id,
    String? userId,
    TreatmentType? type,
    double? measurementValue,
    String? measurementUnit,
    DateTime? timestamp,
  }) {
    return TreatmentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      measurementValue: measurementValue ?? this.measurementValue,
      measurementUnit: measurementUnit ?? this.measurementUnit,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'TreatmentModel(id: $id, userId: $userId, type: ${type.name}, value: $measurementValue $measurementUnit)';
  }
}

/// Tipos de tratamiento
enum TreatmentType {
  diabetes,
  presion,
  otro,
}

extension TreatmentTypeExtension on TreatmentType {
  String get displayName {
    switch (this) {
      case TreatmentType.diabetes:
        return 'Diabetes';
      case TreatmentType.presion:
        return 'Presión Arterial';
      case TreatmentType.otro:
        return 'Otro';
    }
  }
}



