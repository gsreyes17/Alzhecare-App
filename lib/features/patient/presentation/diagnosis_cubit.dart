import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/diagnosis_repository.dart';
import 'diagnosis_state.dart';

class DiagnosisCubit extends Cubit<DiagnosisState> {
  DiagnosisCubit({required DiagnosisRepository diagnosisRepository})
    : _diagnosisRepository = diagnosisRepository,
      super(DiagnosisState.initial());

  final DiagnosisRepository _diagnosisRepository;

  Future<void> loadHistory() async {
    emit(state.copyWith(status: DiagnosisStatus.loading, message: null));
    try {
      final history = await _diagnosisRepository.loadHistory();
      emit(state.copyWith(status: DiagnosisStatus.success, history: history));
    } catch (error) {
      emit(
        state.copyWith(
          status: DiagnosisStatus.failure,
          message: _messageFromError(error),
        ),
      );
    }
  }

  Future<void> analyzeImage({
    required Uint8List bytes,
    required String filename,
  }) async {
    emit(state.copyWith(status: DiagnosisStatus.loading, message: null));
    try {
      final result = await _diagnosisRepository.analyzeImage(
        bytes: bytes,
        filename: filename,
      );
      emit(
        state.copyWith(
          status: DiagnosisStatus.success,
          lastAnalysis: result,
          history: [result, ...state.history],
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: DiagnosisStatus.failure,
          message: _messageFromError(error),
        ),
      );
    }
  }

  /// Analizar imagen a nombre de un paciente (doctor/admin)
  Future<void> analyzeImageForPatient({
    required String patientId,
    required Uint8List bytes,
    required String filename,
  }) async {
    emit(state.copyWith(status: DiagnosisStatus.loading, message: null));
    try {
      final result = await _diagnosisRepository.analyzeImageForPatient(
        patientId: patientId,
        bytes: bytes,
        filename: filename,
      );
      emit(
        state.copyWith(
          status: DiagnosisStatus.success,
          lastAnalysis: result,
          history: [result, ...state.history],
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: DiagnosisStatus.failure,
          message: _messageFromError(error),
        ),
      );
    }
  }

  /// Cargar historial de un paciente (doctor/admin)
  Future<void> loadHistoryForPatient({required String patientId}) async {
    emit(state.copyWith(status: DiagnosisStatus.loading, message: null));
    try {
      final history = await _diagnosisRepository.loadHistoryForPatient(
        patientId: patientId,
      );
      emit(state.copyWith(status: DiagnosisStatus.success, history: history));
    } catch (error) {
      emit(
        state.copyWith(
          status: DiagnosisStatus.failure,
          message: _messageFromError(error),
        ),
      );
    }
  }

  String _messageFromError(Object error) {
    final message = error.toString();
    if (message.startsWith('ApiException')) {
      return message.replaceFirst(RegExp(r'^ApiException\(\d+\):\s*'), '');
    }
    return 'No fue posible procesar la operación';
  }
}
