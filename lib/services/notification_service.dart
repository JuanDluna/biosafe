// BioSafe - archivo generado con IA asistida - revisión: Pablo

import 'dart:io' show Platform;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/notification_model.dart';
import '../models/medicine_model.dart';
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
        // Esto se puede hacer en el servicio de usuario
      }

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

  /// Programar notificación local
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

      // Programar notificación usando show con delay calculado
      final now = DateTime.now();
      if (scheduledDate.isAfter(now)) {
        final delay = scheduledDate.difference(now);
        // Usar show después del delay calculado
        Future.delayed(delay, () async {
          await _localNotifications.show(
            id,
            title,
            body,
            details,
            payload: payload,
          );
        });
      } else {
        // Si la fecha ya pasó, mostrar inmediatamente
        await _localNotifications.show(
          id,
          title,
          body,
          details,
          payload: payload,
        );
      }
    } catch (e) {
      // Error silencioso
    }
  }

  /// Crear notificación de recordatorio de medicamento
  Future<void> createMedicineReminder({
    required String userId,
    required MedicineModel medicine,
    required DateTime reminderTime,
  }) async {
    try {
      final message = 'Es hora de tomar: ${medicine.name} - ${medicine.dosage}';

      // Crear notificación en Firestore
      final notification = NotificationModel(
        userId: userId,
        medicineId: medicine.id,
        time: reminderTime,
        message: message,
        status: NotificationStatus.pending,
      );

      final notificationId = await _firestoreService.createNotification(notification);

      // Programar notificación local
      await scheduleNotification(
        id: int.tryParse(notificationId.substring(0, 8), radix: 16) ??
            DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title: 'Recordatorio de Medicamento',
        body: message,
        scheduledDate: reminderTime,
        payload: medicine.id,
      );
    } catch (e) {
      throw Exception('Error al crear recordatorio: $e');
    }
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

