import '../../../core/models/appointment_record.dart';
import '../../../core/network/api_client.dart';

class AdminAppointmentsRepository {
  AdminAppointmentsRepository({required this.apiClient});

  final ApiClient apiClient;

  Future<List<AppointmentRecord>> listAppointments({String? status}) async {
    final response = await apiClient.getJson(
      '/api/admin/citas',
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
      '/api/admin/citas/$appointmentId/status',
      {'status': status},
    );
    return AppointmentRecord.fromJson(response);
  }
}
