// BioSafe - archivo generado con IA asistida - revisión: Pablo

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../services/database_service.dart';
import '../models/notification_model.dart';
import '../utils/theme.dart';

/// Pantalla de notificaciones y recordatorios
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<NotificationModel> _notifications = [];
  List<NotificationModel> _pendingNotifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.uid;

      if (userId != null) {
        final allNotifications = await _databaseService.getNotifications(userId);
        final pending = await _databaseService.getPendingNotifications(userId);

        setState(() {
          _notifications = allNotifications;
          _pendingNotifications = pending;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar notificaciones: $e')),
        );
      }
    }
  }

  Future<void> _markAsDone(NotificationModel notification) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.uid;

      if (userId != null && notification.id != null) {
        await _databaseService.updateNotificationStatus(
          notification.id!,
          NotificationStatus.done,
        );
        await _loadNotifications();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Recordatorio completado')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar notificación: $e')),
        );
      }
    }
  }

  Future<void> _postpone(NotificationModel notification) async {
    // Posponer notificación 1 hora
    final newTime = notification.time.add(const Duration(hours: 1));
    
    // TODO: Actualizar notificación en Firestore y local
    // Por ahora solo mostramos un mensaje
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recordatorio pospuesto para ${DateFormat('HH:mm').format(newTime)}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recordatorios'),
        backgroundColor: BioSafeTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 28),
            onPressed: _loadNotifications,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadNotifications,
              child: CustomScrollView(
                slivers: [
                  // Sección de pendientes
                  if (_pendingNotifications.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(BioSafeTheme.spacingMedium),
                        child: Text(
                          'Próximos recordatorios',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: BioSafeTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final notification = _pendingNotifications[index];
                          return _buildNotificationCard(notification, isPending: true);
                        },
                        childCount: _pendingNotifications.length,
                      ),
                    ),
                  ],
                  
                  // Sección de completadas
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(BioSafeTheme.spacingMedium),
                      child: Text(
                        'Recordatorios completados',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: BioSafeTheme.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (_notifications.where((n) => n.status == NotificationStatus.done).isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(BioSafeTheme.spacingLarge),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 64,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No hay recordatorios completados',
                                style: TextStyle(
                                  fontSize: BioSafeTheme.fontSizeMedium,
                                  color: BioSafeTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final notification = _notifications
                              .where((n) => n.status == NotificationStatus.done)
                              .toList()[index];
                          return _buildNotificationCard(notification, isPending: false);
                        },
                        childCount: _notifications
                            .where((n) => n.status == NotificationStatus.done)
                            .length,
                      ),
                    ),
                  
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification, {required bool isPending}) {
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('dd/MM/yyyy');
    final isToday = notification.time.day == DateTime.now().day &&
        notification.time.month == DateTime.now().month &&
        notification.time.year == DateTime.now().year;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: BioSafeTheme.spacingMedium,
        vertical: 8,
      ),
      color: isPending
          ? BioSafeTheme.primaryColor.withOpacity(0.1)
          : Colors.white,
      child: ListTile(
        leading: Icon(
          isPending ? Icons.access_time : Icons.check_circle,
          size: 32,
          color: isPending ? BioSafeTheme.warningColor : BioSafeTheme.successColor,
        ),
        title: Text(
          notification.message,
          style: TextStyle(
            fontSize: BioSafeTheme.fontSizeSmall,
            fontWeight: FontWeight.bold,
            color: isPending ? BioSafeTheme.primaryColor : BioSafeTheme.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              isToday
                  ? 'Hoy a las ${timeFormat.format(notification.time)}'
                  : '${dateFormat.format(notification.time)} a las ${timeFormat.format(notification.time)}',
              style: TextStyle(
                fontSize: 14,
                color: BioSafeTheme.textSecondary,
              ),
            ),
          ],
        ),
        trailing: isPending
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.schedule, size: 28),
                    color: BioSafeTheme.primaryColor,
                    onPressed: () => _postpone(notification),
                    tooltip: 'Posponer',
                  ),
                  IconButton(
                    icon: const Icon(Icons.check_circle, size: 28),
                    color: BioSafeTheme.successColor,
                    onPressed: () => _markAsDone(notification),
                    tooltip: 'Marcar como completado',
                  ),
                ],
              )
            : null,
        isThreeLine: true,
      ),
    );
  }
}

