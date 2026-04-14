import 'dart:typed_data';

import '../../../core/models/diagnosis_record.dart';
import '../../../core/network/api_client.dart';

class DiagnosisRepository {
  DiagnosisRepository({required this.apiClient});

  final ApiClient apiClient;

  Future<DiagnosisRecord> analyzeImage({
    required Uint8List bytes,
    required String filename,
  }) async {
    final response = await apiClient.postMultipart(
      '/api/diagnoses/analyze',
      bytes: bytes,
      filename: filename,
    );
    return DiagnosisRecord.fromJson(response);
  }

  Future<List<DiagnosisRecord>> loadHistory({int limit = 50}) async {
    final response = await apiClient.getJson(
      '/api/diagnoses/history',
      queryParameters: {'limit': limit.toString()},
    );
    final diagnoses = response['diagnoses'];
    if (diagnoses is! List) {
      return const [];
    }

    return diagnoses
        .whereType<Map>()
        .map(
          (item) => DiagnosisRecord.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  /// Analizar imagen a nombre de un paciente (para doctor/admin)
  Future<DiagnosisRecord> analyzeImageForPatient({
    required String patientId,
    required Uint8List bytes,
    required String filename,
  }) async {
    final response = await apiClient.postMultipart(
      '/api/doctor/patients/$patientId/analyze',
      bytes: bytes,
      filename: filename,
    );
    return DiagnosisRecord.fromJson(response);
  }

  /// Cargar historial de análisis de un paciente específico (para doctor/admin)
  Future<List<DiagnosisRecord>> loadHistoryForPatient({
    required String patientId,
    int limit = 50,
  }) async {
    final response = await apiClient.getJson(
      '/api/doctor/patients/$patientId/history',
      queryParameters: {'limit': limit.toString()},
    );
    final diagnoses = response['diagnoses'];
    if (diagnoses is! List) {
      return const [];
    }

    return diagnoses
        .whereType<Map>()
        .map(
          (item) => DiagnosisRecord.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }
}
