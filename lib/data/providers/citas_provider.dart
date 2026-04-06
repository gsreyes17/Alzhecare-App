import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../models/cita_model.dart';

class CitasProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  List<CitaModel> _citas = [];
  List<MedicoModel> _medicos = [];
  DisponibilidadResponse? _disponibilidad;
  CitaModel? _citaSeleccionada;
  int _total = 0;
  int _totalPages = 0;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<CitaModel> get citas => _citas;
  List<MedicoModel> get medicos => _medicos;
  DisponibilidadResponse? get disponibilidad => _disponibilidad;
  CitaModel? get citaSeleccionada => _citaSeleccionada;
  int get total => _total;
  int get totalPages => _totalPages;

  Future<void> cargarCitas({
    int? pacienteId,
    int? medicoId,
    int? hospitalId,
    String? estado,
    String? fechaDesde,
    String? fechaHasta,
    int page = 1,
    int limit = 10,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (pacienteId != null) {
        queryParams['paciente_id'] = pacienteId.toString();
      }
      if (medicoId != null) queryParams['medico_id'] = medicoId.toString();
      if (hospitalId != null) {
        queryParams['hospital_id'] = hospitalId.toString();
      }
      if (estado != null) queryParams['estado'] = estado;
      if (fechaDesde != null) queryParams['fecha_desde'] = fechaDesde;
      if (fechaHasta != null) queryParams['fecha_hasta'] = fechaHasta;

      final response = await ApiService.get(
        '/api/citas',
        queryParams: queryParams,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _total = data['total'] ?? 0;
        _totalPages = data['total_pages'] ?? 0;
        _citas = (data['citas'] as List)
            .map((cita) => CitaModel.fromJson(cita))
            .toList();
        print('Citas cargadas: ${_citas.length} de $_total');
      } else {
        throw Exception('Error cargando citas: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = 'Error al cargar citas: $e';
      print('Error en cargarCitas: $e');
      _citas = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cargarMedicos({String? especialidad}) async {
    try {
      final queryParams = <String, String>{};
      if (especialidad != null) queryParams['especialidad'] = especialidad;

      final response = await ApiService.get(
        '/api/medicos',
        queryParams: queryParams,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _medicos = (data as List)
            .map((medico) => MedicoModel.fromJson(medico))
            .toList();
        print('Médicos cargados: ${_medicos.length}');
      } else {
        throw Exception('Error cargando médicos: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = 'Error al cargar médicos: $e';
      print('Error en cargarMedicos: $e');
      _medicos = [];
    }
  }

  Future<CitaModel?> crearCita(CitaCreateRequest citaData) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await ApiService.post('/api/citas', citaData.toJson());

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final nuevaCita = CitaModel.fromJson(data);
        await cargarCitas(); // Recargar lista
        return nuevaCita;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'Error creando cita');
      }
    } catch (e) {
      _errorMessage = 'Error al crear cita: $e';
      print('Error en crearCita: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<CitaModel?> obtenerCita(int citaId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await ApiService.get('/api/citas/$citaId');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _citaSeleccionada = CitaModel.fromJson(data);
        return _citaSeleccionada;
      } else {
        throw Exception('Error obteniendo cita: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = 'Error al obtener cita: $e';
      print('Error en obtenerCita: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> actualizarCita(int citaId, CitaUpdateRequest citaData) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await ApiService.put(
        '/api/citas/$citaId',
        citaData.toJson(),
      );

      if (response.statusCode == 200) {
        await cargarCitas(); // Recargar lista
        return true;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'Error actualizando cita');
      }
    } catch (e) {
      _errorMessage = 'Error al actualizar cita: $e';
      print('Error en actualizarCita: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cambiarEstadoCita(
    int citaId,
    CitaCambiarEstadoRequest estadoData,
  ) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await ApiService.patch(
        '/api/citas/$citaId/estado',
        estadoData.toJson(),
      );

      if (response.statusCode == 200) {
        await cargarCitas(); // Recargar lista
        return true;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'Error cambiando estado');
      }
    } catch (e) {
      _errorMessage = 'Error al cambiar estado: $e';
      print('Error en cambiarEstadoCita: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> eliminarCita(int citaId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await ApiService.delete('/api/citas/$citaId');

      if (response.statusCode == 200) {
        _citas.removeWhere((cita) => cita.id == citaId);
        notifyListeners();
        return true;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'Error eliminando cita');
      }
    } catch (e) {
      _errorMessage = 'Error al eliminar cita: $e';
      print('Error en eliminarCita: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verificarDisponibilidad(
    int medicoId,
    String fecha, {
    int? hospitalId,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final queryParams = <String, String>{'fecha': fecha};
      if (hospitalId != null) {
        queryParams['hospital_id'] = hospitalId.toString();
      }

      final response = await ApiService.get(
        '/api/citas/medico/$medicoId/disponibilidad',
        queryParams: queryParams,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _disponibilidad = DisponibilidadResponse.fromJson(data);
        print('Disponibilidad cargada para médico $medicoId');
      } else {
        throw Exception(
          'Error verificando disponibilidad: ${response.statusCode}',
        );
      }
    } catch (e) {
      _errorMessage = 'Error al verificar disponibilidad: $e';
      print('Error en verificarDisponibilidad: $e');
      _disponibilidad = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void limpiarDisponibilidad() {
    _disponibilidad = null;
    notifyListeners();
  }

  void limpiarCitaSeleccionada() {
    _citaSeleccionada = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
