import '../../../core/models/appointment_record.dart';
import '../../../core/models/basic_user.dart';
import '../../../core/models/binding_request.dart';
import '../../../core/network/api_client.dart';

class DoctorRepository {
  DoctorRepository({required this.apiClient});

  final ApiClient apiClient;

  Future<List<BasicUser>> searchPatients(String query) async {
    final response = await apiClient.getJson(
      '/api/doctor/patients/search',
      queryParameters: {'q': query},
    );

    final candidates = response['patients'] ?? response['items'] ?? response;
    if (candidates is! List) {
      return const [];
    }

    return candidates
        .whereType<Map>()
        .map((item) => BasicUser.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<BindingRequest> sendRequest(String patientUserId) async {
    final response = await apiClient.postJson('/api/doctor/requests', {
      'patient_user_id': patientUserId,
    });
    return BindingRequest.fromJson(response);
  }

  Future<List<BindingRequest>> listRequests() async {
    final response = await apiClient.getJson('/api/doctor/requests');
    final items = response['requests'] ?? response['items'] ?? response;
    if (items is! List) {
      return const [];
    }

    return items
        .whereType<Map>()
        .map((item) => BindingRequest.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<BasicUser>> listLinkedPatients() async {
    final response = await apiClient.getJson('/api/doctor/patients');
    final items = response['patients'] ?? response['items'] ?? response;
    if (items is! List) {
      return const [];
    }

    return items
        .whereType<Map>()
        .map((item) => BasicUser.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<AppointmentRecord> createAppointment({
    required String patientUserId,
    required String title,
    required DateTime dateTime,
    String? description,
  }) async {
    final response = await apiClient.postJson('/api/doctor/appointments', {
      'patient_user_id': patientUserId,
      'title': title,
      'date_time': dateTime.toIso8601String(),
      'description': description ?? '',
    });
    return AppointmentRecord.fromJson(response);
  }

  Future<List<AppointmentRecord>> listAppointments({String? status}) async {
    final response = await apiClient.getJson(
      '/api/doctor/appointments',
      queryParameters: status == null ? null : {'status': status},
    );

    final items = response['appointments'] ?? response['items'] ?? response;
    if (items is! List) {
      return const [];
    }

    return items
        .whereType<Map>()
        .map(
          (item) => AppointmentRecord.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<AppointmentRecord> updateAppointmentStatus({
    required String appointmentId,
    required String status,
  }) async {
    final response = await apiClient.patchJson(
      '/api/doctor/appointments/$appointmentId/status',
      {'status': status},
    );
    return AppointmentRecord.fromJson(response);
  }
}
