// BioSafe - archivo generado con IA asistida - revisión: Pablo

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medicine_model.dart';
import '../models/treatment_model.dart';
import '../models/notification_model.dart';
import '../models/user_model.dart';

/// Servicio para gestión CRUD en Cloud Firestore
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ========== USUARIOS ==========

  /// Crear usuario en Firestore
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toMap());
    } catch (e) {
      throw Exception('Error al crear usuario: $e');
    }
  }

  /// Obtener usuario por UID
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(uid, doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener usuario: $e');
    }
  }

  /// Actualizar usuario
  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).update(user.toMap());
    } catch (e) {
      throw Exception('Error al actualizar usuario: $e');
    }
  }

  /// Agregar familiar vinculado
  Future<void> addLinkedFamily(String uid, String familyUid) async {
    try {
      final userRef = _firestore.collection('users').doc(uid);
      await userRef.update({
        'linked_family': FieldValue.arrayUnion([familyUid]),
      });
    } catch (e) {
      throw Exception('Error al agregar familiar: $e');
    }
  }

  // ========== MEDICAMENTOS ==========

  /// Crear medicamento en Firestore
  Future<String> createMedicine(MedicineModel medicine) async {
    try {
      final docRef = await _firestore
          .collection('medicines')
          .add(medicine.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear medicamento: $e');
    }
  }

  /// Obtener todos los medicamentos de un usuario
  Future<List<MedicineModel>> getMedicines(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('medicines')
          .where('user_id', isEqualTo: userId)
          .orderBy('expiration_date', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => MedicineModel.fromFirestore(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener medicamentos: $e');
    }
  }

  /// Obtener medicamento por ID
  Future<MedicineModel?> getMedicineById(String id) async {
    try {
      final doc = await _firestore.collection('medicines').doc(id).get();
      if (doc.exists) {
        return MedicineModel.fromFirestore(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener medicamento: $e');
    }
  }

  /// Actualizar medicamento
  Future<void> updateMedicine(MedicineModel medicine) async {
    try {
      if (medicine.id == null) {
        throw Exception('El medicamento debe tener un ID para actualizar');
      }
      await _firestore
          .collection('medicines')
          .doc(medicine.id)
          .update(medicine.toFirestore());
    } catch (e) {
      throw Exception('Error al actualizar medicamento: $e');
    }
  }

  /// Eliminar medicamento
  Future<void> deleteMedicine(String id) async {
    try {
      await _firestore.collection('medicines').doc(id).delete();
    } catch (e) {
      throw Exception('Error al eliminar medicamento: $e');
    }
  }

  /// Verificar duplicado por código de barras
  Future<MedicineModel?> findMedicineByBarcode(String userId, String barcode) async {
    try {
      final querySnapshot = await _firestore
          .collection('medicines')
          .where('user_id', isEqualTo: userId)
          .where('barcode', isEqualTo: barcode)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return MedicineModel.fromFirestore(
          querySnapshot.docs.first.id,
          querySnapshot.docs.first.data(),
        );
      }
      return null;
    } catch (e) {
      throw Exception('Error al buscar medicamento por código: $e');
    }
  }

  /// Verificar duplicado por nombre
  Future<MedicineModel?> findMedicineByName(String userId, String name) async {
    try {
      final querySnapshot = await _firestore
          .collection('medicines')
          .where('user_id', isEqualTo: userId)
          .where('name', isEqualTo: name)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return MedicineModel.fromFirestore(
          querySnapshot.docs.first.id,
          querySnapshot.docs.first.data(),
        );
      }
      return null;
    } catch (e) {
      throw Exception('Error al buscar medicamento por nombre: $e');
    }
  }

  // ========== TRATAMIENTOS ==========

  /// Crear tratamiento en Firestore
  Future<String> createTreatment(TreatmentModel treatment) async {
    try {
      final docRef = await _firestore
          .collection('treatments')
          .add(treatment.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear tratamiento: $e');
    }
  }

  /// Obtener tratamientos de un usuario
  Future<List<TreatmentModel>> getTreatments(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('treatments')
          .where('user_id', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => TreatmentModel.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener tratamientos: $e');
    }
  }

  /// Obtener tratamientos por tipo
  Future<List<TreatmentModel>> getTreatmentsByType(
    String userId,
    TreatmentType type,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('treatments')
          .where('user_id', isEqualTo: userId)
          .where('type', isEqualTo: type.name)
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => TreatmentModel.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener tratamientos por tipo: $e');
    }
  }

  /// Eliminar tratamiento
  Future<void> deleteTreatment(String id) async {
    try {
      await _firestore.collection('treatments').doc(id).delete();
    } catch (e) {
      throw Exception('Error al eliminar tratamiento: $e');
    }
  }

  // ========== NOTIFICACIONES ==========

  /// Crear notificación en Firestore
  Future<String> createNotification(NotificationModel notification) async {
    try {
      final docRef = await _firestore
          .collection('notifications')
          .add(notification.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear notificación: $e');
    }
  }

  /// Obtener notificaciones de un usuario
  Future<List<NotificationModel>> getNotifications(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('user_id', isEqualTo: userId)
          .orderBy('time', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => NotificationModel.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener notificaciones: $e');
    }
  }

  /// Obtener notificaciones pendientes
  Future<List<NotificationModel>> getPendingNotifications(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('user_id', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .orderBy('time', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => NotificationModel.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener notificaciones pendientes: $e');
    }
  }

  /// Actualizar estado de notificación
  Future<void> updateNotificationStatus(
    String id,
    NotificationStatus status,
  ) async {
    try {
      await _firestore.collection('notifications').doc(id).update({
        'status': status.name,
      });
    } catch (e) {
      throw Exception('Error al actualizar notificación: $e');
    }
  }

  /// Eliminar notificación
  Future<void> deleteNotification(String id) async {
    try {
      await _firestore.collection('notifications').doc(id).delete();
    } catch (e) {
      throw Exception('Error al eliminar notificación: $e');
    }
  }

  // ========== SINCRONIZACIÓN ==========

  /// Sincronizar todos los datos del usuario
  Future<Map<String, dynamic>> syncUserData(String userId) async {
    try {
      final medicines = await getMedicines(userId);
      final treatments = await getTreatments(userId);
      final notifications = await getNotifications(userId);
      final user = await getUser(userId);

      return {
        'user': user,
        'medicines': medicines,
        'treatments': treatments,
        'notifications': notifications,
      };
    } catch (e) {
      throw Exception('Error al sincronizar datos: $e');
    }
  }
}



