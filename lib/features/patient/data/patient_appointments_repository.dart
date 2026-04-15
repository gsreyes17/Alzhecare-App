import '../../../core/models/appointment_record.dart';
import '../../../core/network/api_client.dart';

class PatientAppointmentsRepository {
  PatientAppointmentsRepository({required this.apiClient});

  final ApiClient apiClient;

  Future<List<AppointmentRecord>> listAppointments({String? status}) async {
    final response = await apiClient.getJson(
      '/api/patient/appointments',
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
}
