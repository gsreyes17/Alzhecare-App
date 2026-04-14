import 'dart:typed_data';

import '../../../core/models/app_user.dart';
import '../../../core/models/user_session.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/session_storage.dart';

class AuthRepository {
  AuthRepository({required this.apiClient, required this.sessionStorage});

  final ApiClient apiClient;
  final SessionStorage sessionStorage;

  Future<UserSession> bootstrap() async {
    final storedSession = await sessionStorage.loadSession();
    if (storedSession == null) {
      throw StateError('No hay sesión guardada');
    }

    final user = await _refreshCurrentUser(storedSession.accessToken);
    final session = UserSession(
      accessToken: storedSession.accessToken,
      user: user,
    );
    await sessionStorage.saveSession(session);
    return session;
  }

  Future<UserSession> login({
    required String username,
    required String password,
  }) async {
    final tokenResponse = await apiClient.postJson('/api/auth/login', {
      'username': username,
      'password': password,
    });

    final token = tokenResponse['access_token']?.toString() ?? '';
    if (token.isEmpty) {
      throw StateError('El backend no devolvió un token válido');
    }

    final user = await _refreshCurrentUser(token);
    final session = UserSession(accessToken: token, user: user);
    await sessionStorage.saveSession(session);
    return session;
  }

  Future<UserSession> register({
    required String username,
    required String password,
    required String name,
    required String lastname,
    required String email,
  }) async {
    await apiClient.postJson('/api/auth/register', {
      'username': username,
      'password': password,
      'name': name,
      'lastname': lastname,
      'email': email,
    });

    return login(username: username, password: password);
  }

  Future<void> logout() async {
    await sessionStorage.clear();
  }

  Future<UserSession> updateProfile({
    required UserSession currentSession,
    String? name,
    String? lastname,
    String? email,
  }) async {
    final body = <String, dynamic>{};
    if (name != null && name.trim().isNotEmpty) {
      body['name'] = name.trim();
    }
    if (lastname != null && lastname.trim().isNotEmpty) {
      body['lastname'] = lastname.trim();
    }
    if (email != null && email.trim().isNotEmpty) {
      body['email'] = email.trim();
    }
    if (body.isEmpty) {
      return currentSession;
    }

    final response = await apiClient.patchJson('/api/auth/me', body);
    final updatedUser = AppUser.fromJson(response);
    final updatedSession = UserSession(
      accessToken: currentSession.accessToken,
      user: updatedUser,
    );
    await sessionStorage.saveSession(updatedSession);
    return updatedSession;
  }

  Future<UserSession> changePassword({
    required UserSession currentSession,
    required String newPassword,
  }) async {
    final password = newPassword.trim();
    if (password.isEmpty) {
      throw StateError('La contraseña no puede estar vacía');
    }

    await apiClient.patchJson('/api/auth/me', {'password': password});
    final refreshedUser = await _refreshCurrentUser(currentSession.accessToken);
    final updatedSession = UserSession(
      accessToken: currentSession.accessToken,
      user: refreshedUser,
    );
    await sessionStorage.saveSession(updatedSession);
    return updatedSession;
  }

  Future<UserSession> uploadProfilePhoto({
    required UserSession currentSession,
    required Uint8List bytes,
    required String filename,
  }) async {
    final response = await apiClient.postMultipart(
      '/api/auth/me/photo',
      bytes: bytes,
      filename: filename,
    );

    final photoUrl = response['profile_image_url']?.toString();
    final updatedUser = photoUrl == null || photoUrl.isEmpty
        ? currentSession.user
        : currentSession.user.copyWith(
            profileImageUrl: photoUrl,
            updatedAt: DateTime.now(),
          );

    final updatedSession = UserSession(
      accessToken: currentSession.accessToken,
      user: updatedUser,
    );
    await sessionStorage.saveSession(updatedSession);
    return updatedSession;
  }

  Future<AppUser> _refreshCurrentUser(String token) async {
    final response = await apiClient.getJson(
      '/api/auth/me',
      tokenOverride: token,
    );
    return AppUser.fromJson(response);
  }
}
