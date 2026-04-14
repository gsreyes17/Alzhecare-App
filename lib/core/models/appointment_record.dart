import 'package:equatable/equatable.dart';

class AppointmentRecord extends Equatable {
  const AppointmentRecord({
    required this.id,
    required this.doctorUserId,
    required this.patientUserId,
    required this.title,
    required this.dateTime,
    required this.status,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.doctorName,
    this.patientName,
  });

  final String id;
  final String doctorUserId;
  final String patientUserId;
  final String title;
  final DateTime dateTime;
  final String status;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? doctorName;
  final String? patientName;

  factory AppointmentRecord.fromJson(Map<String, dynamic> json) {
    return AppointmentRecord(
      id: json['id']?.toString() ?? '',
      doctorUserId: json['doctor_user_id']?.toString() ?? '',
      patientUserId: json['patient_user_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      dateTime:
          DateTime.tryParse(json['date_time']?.toString() ?? '') ??
          DateTime.now(),
      status: json['status']?.toString() ?? 'programada',
      description: json['description']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
      doctorName: json['doctor_name']?.toString(),
      patientName: json['patient_name']?.toString(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    doctorUserId,
    patientUserId,
    title,
    dateTime,
    status,
    description,
    createdAt,
    updatedAt,
    doctorName,
    patientName,
  ];
}
