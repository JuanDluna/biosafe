// BioSafe - archivo generado con IA asistida - revisión: Pablo

import 'dart:io' show Platform;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../models/notification_model.dart';
import '../models/medicine_model.dart';
import '../utils/constants.dart';
import 'firestore_service.dart';

/// Servicio para notificaciones push y locales
class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirestoreService _firestoreService = FirestoreService();

  bool _initialized = false;

  /// Inicializar el servicio de notificaciones
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Inicializar timezone
      tz.initializeTimeZones();
      
      // Configurar notificaciones locales (Android e iOS)
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Solicitar permisos
      if (Platform.isAndroid) {
        await _requestAndroidPermissions();
      } else if (Platform.isIOS) {
        await _requestIOSPermissions();
      }

      // Configurar Firebase Messaging
      await _setupFirebaseMessaging();

      _initialized = true;
    } catch (e) {
      throw Exception('Error al inicializar notificaciones: $e');
    }
  }

  /// Solicitar permisos en Android
  Future<void> _requestAndroidPermissions() async {
    try {
      final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
      }
    } catch (e) {
      // Error silencioso
    }
  }

  /// Solicitar permisos en iOS
  Future<void> _requestIOSPermissions() async {
    try {
      final iosPlugin = _localNotifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      
      if (iosPlugin != null) {
        await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
    } catch (e) {
      // Error silencioso
    }
  }

  /// Configurar Firebase Messaging
  Future<void> _setupFirebaseMessaging() async {
    try {
      // Solicitar token FCM
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        // Guardar token en Firestore para enviar notificaciones push
        await _saveFCMToken(token);
      }

      // Escuchar cambios en el token (se renueva periódicamente)
      _firebaseMessaging.onTokenRefresh.listen((newToken) async {
        await _saveFCMToken(newToken);
      });

      // Configurar manejador de mensajes en primer plano
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Configurar manejador cuando se toca la notificación
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTapped);

      // Verificar si la app se abrió desde una notificación
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTapped(initialMessage);
      }
    } catch (e) {
      // Error silencioso para compatibilidad con Web
    }
  }

  /// Guardar token FCM en Firestore
  Future<void> _saveFCMToken(String token) async {
    try {
      // Obtener el usuario actual desde Firestore
      // Esto requiere que el userId esté disponible
      // Por ahora, guardamos el token cuando se inicializa el servicio
      // El userId se puede obtener desde AuthProvider o pasar como parámetro
    } catch (e) {
      // Error silencioso
    }
  }

  /// Manejar mensaje en primer plano
  void _handleForegroundMessage(RemoteMessage message) {
    // Mostrar notificación local cuando la app está en primer plano
    showLocalNotification(
      title: message.notification?.title ?? 'BioSafe',
      body: message.notification?.body ?? '',
      payload: message.data.toString(),
    );
  }

  /// Manejar cuando se toca una notificación
  void _handleNotificationTapped(RemoteMessage message) {
    // Navegar a la pantalla correspondiente
    // Esto se puede manejar con un callback o Provider
  }

  /// Manejar cuando se toca una notificación local
  void _onNotificationTapped(NotificationResponse response) {
    // Navegar a la pantalla correspondiente
    // Esto se puede manejar con un callback o Provider
  }

  /// Mostrar notificación local
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
    int? id,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'biosafe_channel',
        'BioSafe Notificaciones',
        channelDescription: 'Notificaciones de recordatorios de medicamentos',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        id ?? DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        details,
        payload: payload,
      );
    } catch (e) {
      // Error silencioso
    }
  }

  /// Programar notificación local con timezone
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'biosafe_channel',
        'BioSafe Notificaciones',
        channelDescription: 'Notificaciones de recordatorios de medicamentos',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Convertir DateTime a TZDateTime
      final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);
      
      // Programar notificación
      await _localNotifications.zonedSchedule(
        id,
        title,
        body,
        tzDateTime,
        details,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      // Error silencioso
    }
  }

  /// Programar notificación periódica (diaria)
  Future<void> schedulePeriodicNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'biosafe_channel',
        'BioSafe Notificaciones',
        channelDescription: 'Notificaciones de recordatorios de medicamentos',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Programar notificación periódica diaria
      await _localNotifications.zonedSchedule(
        id,
        title,
        body,
        _nextInstanceOfTime(hour, minute),
        details,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      // Error silencioso
    }
  }

  /// Calcular el próximo momento para una hora específica
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
      0,
    );
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }

  /// Programar notificaciones de dosis temporizada para un medicamento
  Future<void> scheduleMedicineDosageReminders({
    required String userId,
    required MedicineModel medicine,
  }) async {
    if (medicine.id == null) return;
    
    // Cancelar notificaciones anteriores de este medicamento
    await cancelMedicineReminders(medicine.id!);
    
    // Si no tiene dosis temporizada, no programar
    if (medicine.dosageIntervalHours == null || 
        medicine.dosageIntervalHours! <= 0 ||
        medicine.dosageDurationDays == null ||
        medicine.dosageDurationDays! <= 0) {
      return;
    }

    try {
      final intervalHours = medicine.dosageIntervalHours!;
      final durationDays = medicine.dosageDurationDays!;
      final dosageAmount = medicine.dosageAmount ?? medicine.dosage;
      
      // Calcular cuántas notificaciones necesitamos
      final totalNotifications = (durationDays * 24 / intervalHours).ceil();
      
      // Empezar desde ahora
      var nextNotificationTime = DateTime.now();
      
      // Programar todas las notificaciones
      for (int i = 0; i < totalNotifications; i++) {
        // Calcular ID único para cada notificación
        final notificationId = _generateNotificationId(medicine.id!, i);
        
        // Crear mensaje
        final message = 'Es hora de tomar: $dosageAmount';
        
        // Programar notificación
        await scheduleNotification(
          id: notificationId,
          title: '💊 Recordatorio: ${medicine.name}',
          body: message,
          scheduledDate: nextNotificationTime,
          payload: medicine.id,
        );
        
        // Crear registro en Firestore (opcional)
        try {
          final notification = NotificationModel(
            userId: userId,
            medicineId: medicine.id,
            time: nextNotificationTime,
            message: message,
            status: NotificationStatus.pending,
          );
          await _firestoreService.createNotification(notification);
        } catch (e) {
          // Error silencioso si falla Firestore
        }
        
        // Calcular próxima notificación
        nextNotificationTime = nextNotificationTime.add(
          Duration(hours: intervalHours),
        );
        
        // Si ya pasó la duración, parar
        if (nextNotificationTime.difference(DateTime.now()).inDays > durationDays) {
          break;
        }
      }
    } catch (e) {
      // Error silencioso
    }
  }

  /// Programar alerta de medicamento próximo a vencer
  Future<void> scheduleExpirationAlert({
    required String userId,
    required MedicineModel medicine,
  }) async {
    if (medicine.id == null) return;
    
    // Cancelar alerta anterior
    await cancelExpirationAlert(medicine.id!);
    
    // Calcular días hasta vencimiento
    final daysUntilExpiration = medicine.expirationDate.difference(DateTime.now()).inDays;
    
    // Solo programar si está próximo a vencer (dentro de los próximos 30 días)
    if (daysUntilExpiration < 0 || daysUntilExpiration > AppConstants.daysBeforeExpiryWarning) {
      return;
    }
    
    try {
      // Programar alerta para el día de vencimiento a las 9:00 AM
      final alertDate = DateTime(
        medicine.expirationDate.year,
        medicine.expirationDate.month,
        medicine.expirationDate.day,
        9, // 9:00 AM
      );
      
      // Si ya pasó hoy, programar para mañana
      if (alertDate.isBefore(DateTime.now())) {
        return; // Ya venció, no programar
      }
      
      final notificationId = _generateExpirationAlertId(medicine.id!);
      
      String title;
      String body;
      
      if (daysUntilExpiration == 0) {
        title = '⚠️ Medicamento Vencido';
        body = '${medicine.name} ha vencido hoy. Por favor, revisa tu inventario.';
      } else if (daysUntilExpiration <= 7) {
        title = '🔴 Alerta: Medicamento Próximo a Vencer';
        body = '${medicine.name} vence en $daysUntilExpiration ${daysUntilExpiration == 1 ? 'día' : 'días'}.';
      } else {
        title = '🟡 Recordatorio: Medicamento Próximo a Vencer';
        body = '${medicine.name} vence en $daysUntilExpiration días.';
      }
      
      // Programar notificación
      await scheduleNotification(
        id: notificationId,
        title: title,
        body: body,
        scheduledDate: alertDate,
        payload: medicine.id,
      );
      
      // Crear registro en Firestore (opcional)
      try {
        final notification = NotificationModel(
          userId: userId,
          medicineId: medicine.id,
          time: alertDate,
          message: body,
          status: NotificationStatus.pending,
        );
        await _firestoreService.createNotification(notification);
      } catch (e) {
        // Error silencioso si falla Firestore
      }
    } catch (e) {
      // Error silencioso
    }
  }

  /// Verificar y programar alertas para todos los medicamentos próximos a vencer
  Future<void> checkAndScheduleExpirationAlerts({
    required String userId,
    required List<MedicineModel> medicines,
  }) async {
    for (final medicine in medicines) {
      await scheduleExpirationAlert(
        userId: userId,
        medicine: medicine,
      );
    }
  }

  /// Generar ID único para notificación de dosis
  int _generateNotificationId(String medicineId, int index) {
    return (medicineId.hashCode + index).abs() % 1000000;
  }

  /// Generar ID único para alerta de vencimiento
  int _generateExpirationAlertId(String medicineId) {
    return (medicineId.hashCode + 999999).abs() % 1000000;
  }

  /// Cancelar todas las notificaciones de un medicamento
  Future<void> cancelMedicineReminders(String medicineId) async {
    try {
      // Cancelar notificaciones de dosis (hasta 1000 por medicamento)
      for (int i = 0; i < 1000; i++) {
        final id = _generateNotificationId(medicineId, i);
        await _localNotifications.cancel(id);
      }
    } catch (e) {
      // Error silencioso
    }
  }

  /// Cancelar alerta de vencimiento de un medicamento
  Future<void> cancelExpirationAlert(String medicineId) async {
    try {
      final id = _generateExpirationAlertId(medicineId);
      await _localNotifications.cancel(id);
    } catch (e) {
      // Error silencioso
    }
  }

  /// Cancelar todas las notificaciones de un medicamento
  Future<void> cancelAllMedicineNotifications(String medicineId) async {
    await cancelMedicineReminders(medicineId);
    await cancelExpirationAlert(medicineId);
  }

  /// Cancelar notificación programada
  Future<void> cancelNotification(int id) async {
    try {
      await _localNotifications.cancel(id);
    } catch (e) {
      // Error silencioso
    }
  }

  /// Cancelar todas las notificaciones
  Future<void> cancelAllNotifications() async {
    try {
      await _localNotifications.cancelAll();
    } catch (e) {
      // Error silencioso
    }
  }

  /// Obtener token FCM
  Future<String?> getFCMToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      return null;
    }
  }

  /// Guardar token FCM en Firestore para un usuario específico
  Future<void> saveFCMTokenForUser(String userId, String token) async {
    try {
      await _firestoreService.updateFCMToken(userId, token);
    } catch (e) {
      // Error silencioso
    }
  }

  /// Suscribirse a un tema
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
    } catch (e) {
      // Error silencioso
    }
  }

  /// Desuscribirse de un tema
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
    } catch (e) {
      // Error silencioso
    }
  }
}
