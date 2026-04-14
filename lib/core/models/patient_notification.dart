import 'package:equatable/equatable.dart';

class PatientNotification extends Equatable {
  const PatientNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  factory PatientNotification.fromJson(Map<String, dynamic> json) {
    final fallbackType = json['type']?.toString() ?? 'general';
    final fallbackTitle = switch (fallbackType) {
      'solicitud_medico' => 'Nueva solicitud médica',
      'respuesta_solicitud' => 'Respuesta a solicitud',
      'cita_programada' => 'Cita programada',
      'cita_actualizada' => 'Cita actualizada',
      _ => 'Notificación',
    };

    return PatientNotification(
      id: json['id']?.toString() ?? '',
      type: fallbackType,
      title: json['title']?.toString() ?? fallbackTitle,
      message:
          json['message']?.toString() ??
          json['description']?.toString() ??
          'Tienes una nueva notificación.',
      isRead: json['is_read'] == true || json['read'] == true,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, type, title, message, isRead, createdAt];
}
