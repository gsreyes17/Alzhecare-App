import 'package:equatable/equatable.dart';

import '../../../core/models/diagnosis_record.dart';

enum DiagnosisStatus { initial, loading, success, failure }

class DiagnosisState extends Equatable {
  const DiagnosisState({
    required this.status,
    this.history = const [],
    this.lastAnalysis,
    this.message,
  });

  final DiagnosisStatus status;
  final List<DiagnosisRecord> history;
  final DiagnosisRecord? lastAnalysis;
  final String? message;

  factory DiagnosisState.initial() =>
      const DiagnosisState(status: DiagnosisStatus.initial);

  DiagnosisState copyWith({
    DiagnosisStatus? status,
    List<DiagnosisRecord>? history,
    DiagnosisRecord? lastAnalysis,
    String? message,
  }) {
    return DiagnosisState(
      status: status ?? this.status,
      history: history ?? this.history,
      lastAnalysis: lastAnalysis ?? this.lastAnalysis,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, history, lastAnalysis, message];
}
