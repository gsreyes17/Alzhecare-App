import '../../../core/models/basic_user.dart';
import '../../../core/network/api_client.dart';

class AdminUsersRepository {
  AdminUsersRepository({required this.apiClient});

  final ApiClient apiClient;

  Future<List<BasicUser>> searchUsers(String query) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return const [];
    }

    final response = await apiClient.getJson(
      '/api/admin/users',
      queryParameters: {'skip': '0', 'limit': '200'},
    );

    final users = response['users'];
    if (users is! List) {
      return const [];
    }

    final mapped = users
        .whereType<Map>()
        .map((item) => BasicUser.fromJson(Map<String, dynamic>.from(item)))
        .where((user) {
          final name = user.name.toLowerCase();
          final lastname = user.lastname.toLowerCase();
          final username = user.username.toLowerCase();
          final fullName = '${user.name} ${user.lastname}'.toLowerCase();
          return name.contains(normalized) ||
              lastname.contains(normalized) ||
              username.contains(normalized) ||
              fullName.contains(normalized);
        })
        .toList();

    mapped.sort((a, b) => a.fullName.compareTo(b.fullName));
    return mapped;
  }
}
