import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/services/api_service.dart';
import '../models/coordinacion_model.dart';
import '../models/diagnostico_model.dart';

class CoordinacionProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';

  List<UsuarioBasico> _searchPacientes = [];
  List<UsuarioBasico> _pacientesDoctor = [];
  List<SolicitudVinculacion> _solicitudesDoctor = [];
  List<SolicitudVinculacion> _solicitudesPaciente = [];
  List<CitaCoordinacion> _citasDoctor = [];
  List<CitaCoordinacion> _citasPaciente = [];
  List<CitaCoordinacion> _citasAdmin = [];
  List<NotificacionCoordinacion> _notificacionesPaciente = [];
  List<Diagnostico> _historialPacienteSeleccionado = [];

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<UsuarioBasico> get searchPacientes => _searchPacientes;
  List<UsuarioBasico> get pacientesDoctor => _pacientesDoctor;
  List<SolicitudVinculacion> get solicitudesDoctor => _solicitudesDoctor;
  List<SolicitudVinculacion> get solicitudesPaciente => _solicitudesPaciente;
  List<CitaCoordinacion> get citasDoctor => _citasDoctor;
  List<CitaCoordinacion> get citasPaciente => _citasPaciente;
  List<CitaCoordinacion> get citasAdmin => _citasAdmin;
  List<NotificacionCoordinacion> get notificacionesPaciente => _notificacionesPaciente;
  List<Diagnostico> get historialPacienteSeleccionado => _historialPacienteSeleccionado;

  Future<void> buscarPacientes(String texto) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      if (texto.trim().isEmpty) {
        _searchPacientes = [];
      } else {
        final response = await ApiService.get('/api/doctor/pacientes/buscar', queryParams: {'q': texto.trim()});
        if (response.statusCode == 200) {
          final list = json.decode(response.body) as List;
          _searchPacientes = list
              .map((item) => UsuarioBasico.fromJson(Map<String, dynamic>.from(item as Map)))
              .toList();
        } else {
          throw Exception('Error buscando pacientes: ${response.statusCode}');
        }
      }
    } catch (e) {
      _errorMessage = 'Error buscando pacientes: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> enviarSolicitudVinculacion(String patientUserId) async {
    try {
      final response = await ApiService.post('/api/doctor/solicitudes', {'patient_user_id': patientUserId});
      if (response.statusCode == 200) {
        await cargarSolicitudesDoctor();
        return true;
      }
      final error = json.decode(response.body);
      _errorMessage = error['detail']?.toString() ?? 'No se pudo enviar solicitud';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error enviando solicitud: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> cargarSolicitudesDoctor() async {
    try {
      final response = await ApiService.get('/api/doctor/solicitudes');
      if (response.statusCode == 200) {
        final list = json.decode(response.body) as List;
        _solicitudesDoctor = list
            .map((item) => SolicitudVinculacion.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error cargando solicitudes doctor: $e';
      notifyListeners();
    }
  }

  Future<void> cargarPacientesDoctor() async {
    try {
      final response = await ApiService.get('/api/doctor/pacientes');
      if (response.statusCode == 200) {
        final list = json.decode(response.body) as List;
        _pacientesDoctor = list
            .map((item) => UsuarioBasico.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error cargando pacientes del doctor: $e';
      notifyListeners();
    }
  }

  Future<void> cargarHistorialPaciente(String patientUserId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final response = await ApiService.get('/api/doctor/pacientes/$patientUserId/historial');
      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(json.decode(response.body) as Map);
        final list = (data['diagnosticos'] as List? ?? []);
        _historialPacienteSeleccionado = list
            .map((item) => Diagnostico.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      } else {
        throw Exception('Error cargando historial paciente: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = 'Error cargando historial: $e';
      _historialPacienteSeleccionado = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AnalisisResponse?> analizarParaPaciente(String patientUserId, File imagen) async {
    try {
      final response = await ApiService.multipartRequest('/api/doctor/pacientes/$patientUserId/analizar', imagen);
      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(json.decode(response.body) as Map);
        await cargarHistorialPaciente(patientUserId);
        return AnalisisResponse.fromJson(data);
      }
      final error = json.decode(response.body);
      _errorMessage = error['detail']?.toString() ?? 'No se pudo analizar imagen';
      notifyListeners();
      return null;
    } catch (e) {
      _errorMessage = 'Error analizando imagen: $e';
      notifyListeners();
      return null;
    }
  }

  Future<bool> crearCitaDoctor({
    required String patientUserId,
    required String titulo,
    required DateTime fechaHora,
    required String descripcion,
  }) async {
    try {
      final response = await ApiService.post('/api/doctor/citas', {
        'patient_user_id': patientUserId,
        'titulo': titulo,
        'fecha_hora': fechaHora.toIso8601String(),
        'descripcion': descripcion,
      });
      if (response.statusCode == 200) {
        await cargarCitasDoctor();
        return true;
      }
      final error = json.decode(response.body);
      _errorMessage = error['detail']?.toString() ?? 'No se pudo crear cita';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error creando cita: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> cargarCitasDoctor({String? estado}) async {
    try {
      final response = await ApiService.get('/api/doctor/citas', queryParams: estado == null ? null : {'estado': estado});
      if (response.statusCode == 200) {
        final list = json.decode(response.body) as List;
        _citasDoctor = list
            .map((item) => CitaCoordinacion.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error cargando citas doctor: $e';
      notifyListeners();
    }
  }

  Future<bool> actualizarEstadoCitaDoctor(String citaId, String estado) async {
    try {
      final response = await ApiService.patch('/api/doctor/citas/$citaId/estado', {'estado': estado});
      if (response.statusCode == 200) {
        await cargarCitasDoctor();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> cargarSolicitudesPaciente() async {
    try {
      final response = await ApiService.get('/api/patient/solicitudes');
      if (response.statusCode == 200) {
        final list = json.decode(response.body) as List;
        _solicitudesPaciente = list
            .map((item) => SolicitudVinculacion.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error cargando solicitudes paciente: $e';
      notifyListeners();
    }
  }

  Future<bool> responderSolicitudPaciente(String requestId, String accion) async {
    try {
      final response = await ApiService.patch('/api/patient/solicitudes/$requestId', {'accion': accion});
      if (response.statusCode == 200) {
        await cargarSolicitudesPaciente();
        await cargarNotificacionesPaciente();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> cargarNotificacionesPaciente({bool soloNoLeidas = false}) async {
    try {
      final response = await ApiService.get('/api/patient/notificaciones', queryParams: soloNoLeidas ? {'solo_no_leidas': 'true'} : null);
      if (response.statusCode == 200) {
        final list = json.decode(response.body) as List;
        _notificacionesPaciente = list
            .map((item) => NotificacionCoordinacion.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error cargando notificaciones: $e';
      notifyListeners();
    }
  }

  Future<void> marcarNotificacionLeida(String notificationId) async {
    try {
      await ApiService.patch('/api/patient/notificaciones/$notificationId/leida', {});
      await cargarNotificacionesPaciente();
    } catch (_) {}
  }

  Future<void> cargarCitasPaciente({String? estado}) async {
    try {
      final response = await ApiService.get('/api/patient/citas', queryParams: estado == null ? null : {'estado': estado});
      if (response.statusCode == 200) {
        final list = json.decode(response.body) as List;
        _citasPaciente = list
            .map((item) => CitaCoordinacion.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error cargando citas paciente: $e';
      notifyListeners();
    }
  }

  Future<void> cargarCitasAdmin({String? estado}) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await ApiService.get('/api/admin/citas', queryParams: estado == null ? null : {'estado': estado});
      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(json.decode(response.body) as Map);
        final list = data['citas'] as List? ?? [];
        _citasAdmin = list
            .map((item) => CitaCoordinacion.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      } else {
        throw Exception('Error cargando citas admin: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = 'Error cargando citas admin: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> actualizarEstadoCitaAdmin(String citaId, String estado) async {
    try {
      final response = await ApiService.patch('/api/admin/citas/$citaId/estado', {'estado': estado});
      if (response.statusCode == 200) {
        await cargarCitasAdmin();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
