import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';

class MedicoProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  List<dynamic> _misPacientes = [];
  List<dynamic> _historialPacientes = [];
  Map<String, dynamic> _perfilMedico = {};

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<dynamic> get misPacientes => _misPacientes;
  List<dynamic> get historialPacientes => _historialPacientes;
  Map<String, dynamic> get perfilMedico => _perfilMedico;

  Future<void> cargarMisPacientes() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await ApiService.get('/api/medicos/mis-pacientes');

      if (response.statusCode == 200) {
        _misPacientes = json.decode(response.body);
        print('Pacientes cargados: ${_misPacientes.length}');
      } else {
        throw Exception('Error cargando pacientes: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      print('Error en cargarMisPacientes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cargarHistorialPacientes({
    int? pacienteId,
    String? fechaDesde,
    String? fechaHasta,
    int page = 1,
    int perPage = 10,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (pacienteId != null)
        queryParams['paciente_id'] = pacienteId.toString();
      if (fechaDesde != null) queryParams['fecha_desde'] = fechaDesde;
      if (fechaHasta != null) queryParams['fecha_hasta'] = fechaHasta;

      final response = await ApiService.get(
        '/api/medico/historial-pacientes',
        queryParams: queryParams,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _historialPacientes = data['diagnosticos'] ?? [];
        print(
          'Historial de pacientes cargado: ${_historialPacientes.length} registros',
        );
      } else {
        throw Exception('Error cargando historial: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      print('Error en cargarHistorialPacientes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cargarPerfilMedico() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await ApiService.get('/api/medicos/perfil');

      if (response.statusCode == 200) {
        _perfilMedico = json.decode(response.body);
        print('Perfil médico cargado');
      } else {
        throw Exception('Error cargando perfil: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      print('Error en cargarPerfilMedico: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
