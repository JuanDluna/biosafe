// BioSafe - archivo generado con IA asistida - revisión: Pablo

/// Modelo de Notificación según esquema Firestore
class NotificationModel {
  final String? id; // ID del documento Firestore
  final String userId; // uid del usuario
  final String? medicineId; // Referencia al medicamento
  final DateTime time; // Timestamp de la notificación
  final String message;
  final NotificationStatus status; // "pending", "done"

  NotificationModel({
    this.id,
    required this.userId,
    this.medicineId,
    required this.time,
    required this.message,
    required this.status,
  });

  /// Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'medicine_id': medicineId,
      'time': time.toIso8601String(),
      'message': message,
      'status': status.name,
    };
  }

  /// Crear desde Map de Firestore
  factory NotificationModel.fromMap(String id, Map<String, dynamic> map) {
    return NotificationModel(
      id: id,
      userId: map['user_id'] as String? ?? '',
      medicineId: map['medicine_id'] as String?,
      time: map['time'] != null
          ? DateTime.parse(map['time'] as String)
          : DateTime.now(),
      message: map['message'] as String? ?? '',
      status: NotificationStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => NotificationStatus.pending,
      ),
    );
  }

  /// Crear copia con campos modificados
  NotificationModel copyWith({
    String? id,
    String? userId,
    String? medicineId,
    DateTime? time,
    String? message,
    NotificationStatus? status,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      medicineId: medicineId ?? this.medicineId,
      time: time ?? this.time,
      message: message ?? this.message,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, userId: $userId, time: $time, status: ${status.name})';
  }
}

/// Estado de la notificación
enum NotificationStatus {
  pending,
  done,
}

extension NotificationStatusExtension on NotificationStatus {
  String get displayName {
    switch (this) {
      case NotificationStatus.pending:
        return 'Pendiente';
      case NotificationStatus.done:
        return 'Completada';
    }
  }
}



