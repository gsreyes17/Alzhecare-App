import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/api_service.dart';
import '../models/auth_model.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isLoggedIn = false;
  String _userRole = '';
  String _userName = '';
  UserResponse? _currentUser;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get isLoggedIn => _isLoggedIn;
  String get userRole => _userRole;
  String get userRoleLabel => _userRole.roleLabel;
  String get userName => _userName;
  UserResponse? get currentUser => _currentUser;

  AuthProvider() {
    _loadAuthStatus();
  }

  dynamic get pacienteId => null;

  Future<void> _loadAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      _userRole = _normalizeRole(prefs.getString('userRole') ?? '');
      _userName = prefs.getString('userName') ?? '';
      final currentUserJson = prefs.getString('currentUser');
      if (currentUserJson != null && currentUserJson.isNotEmpty) {
        _currentUser = UserResponse.fromJson(
          Map<String, dynamic>.from(json.decode(currentUserJson) as Map),
        );
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error cargando estado de autenticación: $e';
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await ApiService.post('/api/auth/login', {
        'username': username,
        'password': password,
      });

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(json.decode(response.body));
        final user = await _getCurrentUser(authResponse.accessToken);

        await _saveAuthData(authResponse.accessToken, user);
        return true;
      } else {
        final error = json.decode(response.body);
        _errorMessage = error['detail'] ?? 'Error en el login';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<UserResponse> _getCurrentUser(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);

    final response = await ApiService.get('/api/auth/me');

    if (response.statusCode == 200) {
      return UserResponse.fromJson(
        Map<String, dynamic>.from(json.decode(response.body) as Map),
      );
    } else {
      throw Exception('Error obteniendo usuario actual');
    }
  }

  Future<void> _saveAuthData(String token, UserResponse user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userRole', user.role);
    await prefs.setString('userName', user.nombre);
    await prefs.setString('authToken', token);
    await prefs.setString('currentUser', json.encode({
      'id': user.id,
      'username': user.username,
      'nombre': user.nombre,
      'apellido': user.apellido,
      'email': user.email,
      'role': user.role,
      'estado': user.estado,
      'profile_image_url': user.profileImageUrl,
      'created_at': user.createdAt.toIso8601String(),
      'updated_at': user.updatedAt.toIso8601String(),
    }));

    _isLoggedIn = true;
    _userRole = _normalizeRole(user.role);
    _userName = user.nombre;
    _currentUser = user;
  }

  Future<bool> refreshCurrentUser() async {
    try {
      final response = await ApiService.get('/api/auth/me');
      if (response.statusCode != 200) {
        _errorMessage = 'No se pudo refrescar el perfil';
        notifyListeners();
        return false;
      }

      final user = UserResponse.fromJson(
        Map<String, dynamic>.from(json.decode(response.body) as Map),
      );

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken') ?? '';
      await _saveAuthData(token, user);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error refrescando perfil: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCurrentUserProfile(UserProfileUpdateRequest request) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await ApiService.patch('/api/auth/me', request.toJson());
      if (response.statusCode != 200) {
        final error = Map<String, dynamic>.from(json.decode(response.body) as Map);
        _errorMessage = error['detail']?.toString() ?? 'No se pudo actualizar el perfil';
        return false;
      }

      final user = UserResponse.fromJson(
        Map<String, dynamic>.from(json.decode(response.body) as Map),
      );
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken') ?? '';
      await _saveAuthData(token, user);
      return true;
    } catch (e) {
      _errorMessage = 'Error actualizando perfil: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadProfilePhoto(File imageFile) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await ApiService.multipartRequest('/api/auth/me/photo', imageFile);
      if (response.statusCode != 200) {
        final error = Map<String, dynamic>.from(json.decode(response.body) as Map);
        _errorMessage = error['detail']?.toString() ?? 'No se pudo subir la foto';
        return false;
      }
      return await refreshCurrentUser();
    } catch (e) {
      _errorMessage = 'Error subiendo foto: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(RegisterRequest request) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await ApiService.post(
        '/api/auth/register',
        request.toJson(),
      );

      if (response.statusCode == 201) {
        // Login automático después del registro
        return await login(request.username, request.password);
      } else {
        final error = json.decode(response.body);
        _errorMessage = error['detail'] ?? 'Error en el registro';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _isLoggedIn = false;
    _userRole = '';
    _userName = '';
    _currentUser = null;
    _errorMessage = '';
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  String _normalizeRole(String role) {
    switch (role.toLowerCase()) {
      case 'patient':
      case 'paciente':
        return 'patient';
      case 'doctor':
      case 'medico':
        return 'doctor';
      case 'admin':
        return 'admin';
      default:
        return role.toLowerCase();
    }
  }
}
