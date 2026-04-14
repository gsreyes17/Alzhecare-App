import 'package:equatable/equatable.dart';

class BindingRequest extends Equatable {
  const BindingRequest({
    required this.id,
    required this.doctorUserId,
    required this.patientUserId,
    required this.status,
    required this.createdAt,
    this.doctorName,
    this.patientName,
  });

  final String id;
  final String doctorUserId;
  final String patientUserId;
  final String status;
  final DateTime createdAt;
  final String? doctorName;
  final String? patientName;

  factory BindingRequest.fromJson(Map<String, dynamic> json) {
    return BindingRequest(
      id: json['id']?.toString() ?? '',
      doctorUserId: json['doctor_user_id']?.toString() ?? '',
      patientUserId: json['patient_user_id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pendiente',
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      doctorName: json['doctor_name']?.toString(),
      patientName: json['patient_name']?.toString(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    doctorUserId,
    patientUserId,
    status,
    createdAt,
    doctorName,
    patientName,
  ];
}
