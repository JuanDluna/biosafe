// BioSafe - archivo generado con IA asistida - revisión: Pablo

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/medicine_model.dart';
import '../models/treatment_model.dart';
import '../models/notification_model.dart';

/// Servicio para manejar la base de datos local SQLite con sincronización Firestore
class DatabaseService {
  static Database? _database;
  static const String _dbName = 'biosafe.db';
  static const int _dbVersion = 3; // Versión actualizada para incluir descripción y dosis temporizada
  
  // Nombres de tablas
  static const String _tableMedicines = 'medicines';
  static const String _tableTreatments = 'treatments';
  static const String _tableNotifications = 'notifications';

  // Patrón Singleton
  static DatabaseService? _instance;
  DatabaseService._internal();
  
  factory DatabaseService() {
    _instance ??= DatabaseService._internal();
    return _instance!;
  }

  /// Obtener o crear la base de datos
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Inicializar la base de datos
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Crear tablas
  Future<void> _onCreate(Database db, int version) async {
    // Tabla de medicamentos
    await db.execute('''
      CREATE TABLE $_tableMedicines (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firestore_id TEXT,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        type TEXT NOT NULL,
        total_quantity INTEGER NOT NULL,
        remaining_quantity INTEGER,
        dosage TEXT NOT NULL,
        dosage_amount TEXT,
        dosage_interval_hours INTEGER,
        dosage_duration_days INTEGER,
        expiration_date TEXT NOT NULL,
        photo_url TEXT,
        barcode TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Tabla de tratamientos
    await db.execute('''
      CREATE TABLE $_tableTreatments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firestore_id TEXT,
        user_id TEXT NOT NULL,
        type TEXT NOT NULL,
        measurement_value REAL NOT NULL,
        measurement_unit TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    // Tabla de notificaciones
    await db.execute('''
      CREATE TABLE $_tableNotifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firestore_id TEXT,
        user_id TEXT NOT NULL,
        medicine_id TEXT,
        time TEXT NOT NULL,
        message TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''');

    // Índices para mejorar rendimiento
    await db.execute('CREATE INDEX idx_medicines_user_id ON $_tableMedicines(user_id)');
    await db.execute('CREATE INDEX idx_medicines_firestore_id ON $_tableMedicines(firestore_id)');
    await db.execute('CREATE INDEX idx_treatments_user_id ON $_tableTreatments(user_id)');
    await db.execute('CREATE INDEX idx_notifications_user_id ON $_tableNotifications(user_id)');
  }

  /// Actualizar esquema de base de datos
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migrar a versión 2 con nuevo esquema
      await db.execute('DROP TABLE IF EXISTS $_tableMedicines');
      await db.execute('DROP TABLE IF EXISTS $_tableTreatments');
      await db.execute('DROP TABLE IF EXISTS $_tableNotifications');
      await _onCreate(db, newVersion);
    } else if (oldVersion < 3) {
      // Migrar a versión 3: agregar campos de descripción y dosis temporizada
      try {
        await db.execute('ALTER TABLE $_tableMedicines ADD COLUMN description TEXT NOT NULL DEFAULT ""');
      } catch (e) {
        // Si la columna ya existe, ignorar
      }
      try {
        await db.execute('ALTER TABLE $_tableMedicines ADD COLUMN dosage_amount TEXT');
      } catch (e) {
        // Si la columna ya existe, ignorar
      }
      try {
        await db.execute('ALTER TABLE $_tableMedicines ADD COLUMN dosage_interval_hours INTEGER');
      } catch (e) {
        // Si la columna ya existe, ignorar
      }
      try {
        await db.execute('ALTER TABLE $_tableMedicines ADD COLUMN dosage_duration_days INTEGER');
      } catch (e) {
        // Si la columna ya existe, ignorar
      }
    }
  }

  // ========== MEDICAMENTOS ==========

  /// Insertar medicamento localmente
  Future<int> insertMedicine(MedicineModel medicine) async {
    final db = await database;
    return await db.insert(_tableMedicines, medicine.toMap());
  }

  /// Obtener todos los medicamentos de un usuario
  Future<List<MedicineModel>> getMedicines(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableMedicines,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'expiration_date ASC',
    );
    return maps.map((map) => MedicineModel.fromMap(map)).toList();
  }

  /// Obtener medicamento por ID local
  Future<MedicineModel?> getMedicineById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableMedicines,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return MedicineModel.fromMap(maps.first);
  }

  /// Obtener medicamento por Firestore ID
  Future<MedicineModel?> getMedicineByFirestoreId(String firestoreId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableMedicines,
      where: 'firestore_id = ?',
      whereArgs: [firestoreId],
    );
    if (maps.isEmpty) return null;
    return MedicineModel.fromMap(maps.first);
  }

  /// Actualizar medicamento localmente
  Future<int> updateMedicine(MedicineModel medicine) async {
    final db = await database;
    if (medicine.id == null) {
      // Si no tiene ID local, buscar por Firestore ID
      if (medicine.id != null) {
        return await db.update(
          _tableMedicines,
          medicine.toMap(),
          where: 'firestore_id = ?',
          whereArgs: [medicine.id],
        );
      }
      return 0;
    }
    return await db.update(
      _tableMedicines,
      medicine.toMap(),
      where: 'id = ?',
      whereArgs: [medicine.id?.hashCode],
    );
  }

  /// Eliminar medicamento localmente
  Future<int> deleteMedicine(int id) async {
    final db = await database;
    return await db.delete(
      _tableMedicines,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Eliminar medicamento por Firestore ID
  Future<int> deleteMedicineByFirestoreId(String firestoreId) async {
    final db = await database;
    return await db.delete(
      _tableMedicines,
      where: 'firestore_id = ?',
      whereArgs: [firestoreId],
    );
  }

  /// Obtener medicamentos próximos a vencer
  Future<List<MedicineModel>> getExpiringMedicines(String userId) async {
    final db = await database;
    final now = DateTime.now();
    final threshold = now.add(const Duration(days: 30));
    
    final List<Map<String, dynamic>> maps = await db.query(
      _tableMedicines,
      where: 'user_id = ? AND expiration_date <= ? AND expiration_date >= ?',
      whereArgs: [userId, threshold.toIso8601String(), now.toIso8601String()],
      orderBy: 'expiration_date ASC',
    );
    return maps.map((map) => MedicineModel.fromMap(map)).toList();
  }

  /// Obtener medicamentos vencidos
  Future<List<MedicineModel>> getExpiredMedicines(String userId) async {
    final db = await database;
    final now = DateTime.now();
    
    final List<Map<String, dynamic>> maps = await db.query(
      _tableMedicines,
      where: 'user_id = ? AND expiration_date < ?',
      whereArgs: [userId, now.toIso8601String()],
      orderBy: 'expiration_date ASC',
    );
    return maps.map((map) => MedicineModel.fromMap(map)).toList();
  }

  /// Limpiar todos los medicamentos de un usuario
  Future<int> clearAllMedicines(String userId) async {
    final db = await database;
    return await db.delete(
      _tableMedicines,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // ========== TRATAMIENTOS ==========

  /// Insertar tratamiento localmente
  Future<int> insertTreatment(TreatmentModel treatment) async {
    final db = await database;
    final map = treatment.toMap();
    map['firestore_id'] = treatment.id;
    return await db.insert(_tableTreatments, map);
  }

  /// Obtener tratamientos de un usuario
  Future<List<TreatmentModel>> getTreatments(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableTreatments,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
    );
    return maps.map((map) {
      final id = map['firestore_id'] as String?;
      map.remove('id');
      map.remove('firestore_id');
      return TreatmentModel.fromMap(id ?? '', map);
    }).toList();
  }

  /// Eliminar tratamiento por Firestore ID
  Future<int> deleteTreatmentByFirestoreId(String firestoreId) async {
    final db = await database;
    return await db.delete(
      _tableTreatments,
      where: 'firestore_id = ?',
      whereArgs: [firestoreId],
    );
  }

  // ========== NOTIFICACIONES ==========

  /// Insertar notificación localmente
  Future<int> insertNotification(NotificationModel notification) async {
    final db = await database;
    final map = notification.toMap();
    map['firestore_id'] = notification.id;
    return await db.insert(_tableNotifications, map);
  }

  /// Obtener notificaciones de un usuario
  Future<List<NotificationModel>> getNotifications(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableNotifications,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'time ASC',
    );
    return maps.map((map) {
      final id = map['firestore_id'] as String?;
      map.remove('id');
      map.remove('firestore_id');
      return NotificationModel.fromMap(id ?? '', map);
    }).toList();
  }

  /// Obtener notificaciones pendientes
  Future<List<NotificationModel>> getPendingNotifications(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableNotifications,
      where: 'user_id = ? AND status = ?',
      whereArgs: [userId, 'pending'],
      orderBy: 'time ASC',
    );
    return maps.map((map) {
      final id = map['firestore_id'] as String?;
      map.remove('id');
      map.remove('firestore_id');
      return NotificationModel.fromMap(id ?? '', map);
    }).toList();
  }

  /// Actualizar estado de notificación
  Future<int> updateNotificationStatus(String firestoreId, NotificationStatus status) async {
    final db = await database;
    return await db.update(
      _tableNotifications,
      {'status': status.name},
      where: 'firestore_id = ?',
      whereArgs: [firestoreId],
    );
  }

  /// Eliminar notificación por Firestore ID
  Future<int> deleteNotificationByFirestoreId(String firestoreId) async {
    final db = await database;
    return await db.delete(
      _tableNotifications,
      where: 'firestore_id = ?',
      whereArgs: [firestoreId],
    );
  }

  // ========== SINCRONIZACIÓN ==========

  /// Limpiar todos los datos de un usuario (útil para resincronización)
  Future<void> clearAllUserData(String userId) async {
    final db = await database;
    await db.delete(_tableMedicines, where: 'user_id = ?', whereArgs: [userId]);
    await db.delete(_tableTreatments, where: 'user_id = ?', whereArgs: [userId]);
    await db.delete(_tableNotifications, where: 'user_id = ?', whereArgs: [userId]);
  }
}

