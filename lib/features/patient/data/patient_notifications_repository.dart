import '../../../core/models/patient_notification.dart';
import '../../../core/network/api_client.dart';

class PatientNotificationsRepository {
  PatientNotificationsRepository({required this.apiClient});

  final ApiClient apiClient;

  Future<List<PatientNotification>> listNotifications({
    bool unreadOnly = false,
  }) async {
    final response = await apiClient.getJson(
      '/api/patient/notifications',
      queryParameters: {'unread_only': unreadOnly.toString()},
    );

    final items = response['notifications'] ?? response['items'] ?? response;
    if (items is! List) {
      return const [];
    }

    return items
        .whereType<Map>()
        .map(
          (item) =>
              PatientNotification.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<void> markAsRead(String notificationId) async {
    await apiClient.patchJson(
      '/api/patient/notifications/$notificationId/read',
      {},
    );
  }
}
