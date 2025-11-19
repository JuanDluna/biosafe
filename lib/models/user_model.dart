// BioSafe - archivo generado con IA asistida - revisión: Pablo

/// Modelo de Usuario según esquema Firestore
class UserModel {
  final String uid; // ID del documento (FirebaseAuth uid)
  final String name;
  final String email;
  final int? age;
  final List<String>? linkedFamily; // Array de uids de familiares
  final String? fcmToken; // Token FCM para notificaciones push
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.age,
    this.linkedFamily,
    this.fcmToken,
    required this.createdAt,
  });

  /// Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'age': age,
      'linked_family': linkedFamily,
      'fcm_token': fcmToken,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Crear desde Map de Firestore
  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      age: map['age'] as int?,
      linkedFamily: map['linked_family'] != null
          ? List<String>.from(map['linked_family'] as List)
          : null,
      fcmToken: map['fcm_token'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
    );
  }

  /// Crear copia con campos modificados
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    int? age,
    List<String>? linkedFamily,
    String? fcmToken,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      linkedFamily: linkedFamily ?? this.linkedFamily,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, name: $name, email: $email, age: $age)';
  }
}



