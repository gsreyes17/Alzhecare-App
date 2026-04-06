import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../models/auth_model.dart';
import '../models/dashboard_models.dart';

class AdminProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  List<UserResponse> _users = [];
  int _total = 0;
  final List<dynamic> _emptyList = [];

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<UserResponse> get users => _users;
  int get total => _total;
  List<dynamic> get historialCompleto => _emptyList;
  Map<String, dynamic> get estadisticasGlobales => {'total_usuarios': _total};
  DashboardCompleto? get dashboardCompleto => null;
  EstadisticasGenerales? get estadisticasGenerales => null;
  List<DiagnosticoPorClasificacion> get diagnosticosPorClasificacion => [];
  List<CitasPorHospital> get citasPorHospital => [];
  List<PacienteDetallado> get pacientesDestacados => [];
  List<MedicoEstadisticas> get medicosEstadisticas => [];
  List<ActividadReciente> get actividadReciente => [];
  List<DiagnosticosPorMes> get tendenciasMensuales => [];

  Future<void> cargarUsuarios({
    String? role,
    bool? estado,
    int skip = 0,
    int limit = 50,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final queryParams = <String, String>{
        'skip': skip.toString(),
        'limit': limit.toString(),
      };

      if (role != null && role.isNotEmpty) {
        queryParams['role'] = role;
      }
      if (estado != null) {
        queryParams['estado'] = estado.toString();
      }

      final response = await ApiService.get(
        '/api/admin/users',
        queryParams: queryParams,
      );

      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(json.decode(response.body) as Map);
        final responseData = UsersListResponse.fromJson(data);
        _users = responseData.users;
        _total = responseData.total;
      } else {
        throw Exception('Error cargando usuarios: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      _users = [];
      _total = 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<UserResponse?> crearUsuario(AdminCreateUserRequest payload) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await ApiService.post('/api/admin/users', payload.toJson());

      if (response.statusCode == 201) {
        final data = Map<String, dynamic>.from(json.decode(response.body) as Map);
        await cargarUsuarios();
        return UserResponse.fromJson(data);
      }

      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'Error creando usuario');
    } catch (e) {
      _errorMessage = 'Error creando usuario: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<UserResponse?> obtenerUsuario(String userId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await ApiService.get('/api/admin/users/$userId');

      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(json.decode(response.body) as Map);
        return UserResponse.fromJson(data);
      }

      throw Exception('Error obteniendo usuario: ${response.statusCode}');
    } catch (e) {
      _errorMessage = 'Error obteniendo usuario: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<UserResponse?> actualizarUsuario(String userId, AdminUpdateUserRequest payload) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await ApiService.patch('/api/admin/users/$userId', payload.toJson());

      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(json.decode(response.body) as Map);
        await cargarUsuarios();
        return UserResponse.fromJson(data);
      }

      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'Error actualizando usuario');
    } catch (e) {
      _errorMessage = 'Error actualizando usuario: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  Future<void> cargarHistorialCompleto({
    int? pacienteId,
    String? fechaDesde,
    String? fechaHasta,
    String? resultado,
    int page = 1,
    int perPage = 10,
  }) async {
    await cargarUsuarios();
  }

  Future<void> cargarEstadisticasGlobales() async {
    await cargarUsuarios();
  }

  Future<void> cargarDashboardCompleto() async {
    await cargarUsuarios();
  }

  Future<void> cargarEstadisticasGeneralesDashboard() async {}

  Future<void> cargarDiagnosticosPorClasificacion() async {}

  Future<void> cargarCitasPorHospital() async {}

  Future<void> cargarPacientesDestacados({int limit = 10}) async {}

  Future<void> cargarMedicosEstadisticas({int limit = 10}) async {}

  Future<void> cargarActividadReciente({int limit = 20}) async {}

  Future<void> cargarTendenciasMensuales({int meses = 6}) async {}

  Future<Map<String, dynamic>> cargarEstadisticasPersonalizadas({
    String? fechaInicio,
    String? fechaFin,
  }) async {
    return {};
  }
}
