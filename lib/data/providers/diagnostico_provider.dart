import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../models/diagnostico_model.dart';

class DiagnosticoProvider with ChangeNotifier {
  List<Diagnostico> _diagnosticos = [];
  DiagnosticoDetalle? _diagnosticoDetalle;
  bool _isLoading = false;
  bool _isLoadingHistorial = false;
  bool _isLoadingDetalle = false;
  String _errorMessage = '';

  bool _hasMore = true;

  List<Diagnostico> get diagnosticos => _diagnosticos;
  DiagnosticoDetalle? get diagnosticoDetalle => _diagnosticoDetalle;
  bool get isLoading => _isLoading;
  bool get isLoadingHistorial => _isLoadingHistorial;
  bool get isLoadingDetalle => _isLoadingDetalle;
  String get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  Future<void> cargarHistorial({bool loadMore = false}) async {
    if (!loadMore) {
      _diagnosticos.clear();
      _hasMore = false;
    }

    _isLoadingHistorial = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await ApiService.get('/api/diagnosticos/mis-diagnosticos');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as List;
        final diagnosticosList = responseData
            .map((item) => Diagnostico.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();

        _diagnosticos = loadMore ? [..._diagnosticos, ...diagnosticosList] : diagnosticosList;
        _hasMore = false;
      } else {
        throw Exception(
          'Error obteniendo historial: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      _errorMessage = 'Error cargando historial: $e';
    } finally {
      _isLoadingHistorial = false;
      notifyListeners();
    }
  }

  Future<void> cargarMasDiagnosticos() async {
    if (_hasMore && !_isLoadingHistorial) {
      await cargarHistorial(loadMore: true);
    }
  }

  Future<void> cargarDetalleDiagnostico(String diagnosticoId) async {
    _isLoadingDetalle = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await ApiService.get('/api/diagnosticos/$diagnosticoId');

      if (response.statusCode == 200) {
        final jsonResponse = Map<String, dynamic>.from(json.decode(response.body) as Map);
        _diagnosticoDetalle = DiagnosticoDetalle.fromJson(jsonResponse);
      } else {
        throw Exception('Error obteniendo detalle: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = 'Error cargando detalle: $e';
      rethrow;
    } finally {
      _isLoadingDetalle = false;
      notifyListeners();
    }
  }

  Future<AnalisisResponse> analizarImagen(File imagen) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await ApiService.multipartRequest(
        '/api/diagnosticos/analizar',
        imagen,
      );

      if (response.statusCode == 200) {
        final jsonResponse = Map<String, dynamic>.from(json.decode(response.body) as Map);
        final resultado = AnalisisResponse.fromJson(jsonResponse);

        // Recargar historial después del análisis
        await cargarHistorial();
        return resultado;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Error analizando imagen');
      }
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void limpiarDetalle() {
    _diagnosticoDetalle = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
