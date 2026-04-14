import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/models/patient_notification.dart';
import '../data/patient_notifications_repository.dart';

class PatientNotificationsPage extends StatefulWidget {
  const PatientNotificationsPage({super.key});

  @override
  State<PatientNotificationsPage> createState() =>
      _PatientNotificationsPageState();
}

class _PatientNotificationsPageState extends State<PatientNotificationsPage> {
  bool _loading = true;
  bool _unreadOnly = false;
  List<PatientNotification> _notifications = const [];

  PatientNotificationsRepository get _repository =>
      context.read<PatientNotificationsRepository>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadNotifications());
  }

  Future<void> _loadNotifications() async {
    setState(() => _loading = true);
    try {
      final items = await _repository.listNotifications(
        unreadOnly: _unreadOnly,
      );
      if (!mounted) return;
      setState(() => _notifications = items);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No fue posible cargar notificaciones: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _markAsRead(PatientNotification notification) async {
    try {
      await _repository.markAsRead(notification.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notificación marcada como leída')),
      );
      await _loadNotifications();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No fue posible actualizar: $error')),
      );
    }
  }

  IconData _iconForType(String type) {
    return switch (type) {
      'solicitud_medico' => Icons.person_add_alt_1_outlined,
      'respuesta_solicitud' => Icons.mark_email_read_outlined,
      'cita_programada' => Icons.event_available_outlined,
      'cita_actualizada' => Icons.event_note_outlined,
      _ => Icons.notifications_none_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Notificaciones',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
              ),
              FilterChip(
                selected: _unreadOnly,
                label: const Text('Solo no leídas'),
                onSelected: (value) {
                  setState(() => _unreadOnly = value);
                  _loadNotifications();
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_notifications.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No tienes notificaciones para mostrar.'),
              ),
            )
          else
            ..._notifications.map((notification) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: notification.isRead
                        ? Colors.grey.shade200
                        : Colors.blue.shade100,
                    child: Icon(
                      _iconForType(notification.type),
                      color: notification.isRead
                          ? Colors.grey.shade700
                          : Colors.blue.shade700,
                    ),
                  ),
                  title: Text(notification.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notification.message),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat(
                          'dd/MM/yyyy HH:mm',
                        ).format(notification.createdAt),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: notification.isRead
                      ? const Chip(label: Text('Leída'))
                      : OutlinedButton(
                          onPressed: () => _markAsRead(notification),
                          child: const Text('Marcar leída'),
                        ),
                  isThreeLine: true,
                ),
              );
            }),
        ],
      ),
    );
  }
}
