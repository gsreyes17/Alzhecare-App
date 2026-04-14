import '../../../core/models/binding_request.dart';
import '../../../core/network/api_client.dart';

class PatientRequestsRepository {
  PatientRequestsRepository({required this.apiClient});

  final ApiClient apiClient;

  Future<List<BindingRequest>> listPendingRequests() async {
    final response = await apiClient.getJson('/api/patient/requests');
    final items = response['requests'] ?? response['items'] ?? response;
    if (items is! List) {
      return const [];
    }

    return items
        .whereType<Map>()
        .map((item) => BindingRequest.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<BindingRequest> respondRequest({
    required String requestId,
    required String action,
  }) async {
    final response = await apiClient.patchJson(
      '/api/patient/requests/$requestId',
      {'action': action},
    );

    return BindingRequest.fromJson(response);
  }
}
