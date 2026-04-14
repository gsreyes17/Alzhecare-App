import 'package:equatable/equatable.dart';

class DiagnosisRecord extends Equatable {
  const DiagnosisRecord({
    required this.id,
    required this.result,
    required this.confidence,
    required this.imageUrl,
    required this.createdAt,
    this.userId,
    this.updatedAt,
    this.status,
    this.modelOutput,
  });

  final String id;
  final String? userId;
  final String result;
  final double confidence;
  final String? status;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? modelOutput;

  factory DiagnosisRecord.fromJson(Map<String, dynamic> json) {
    final rawModelOutput = json['model_output'];
    final modelOutput = rawModelOutput is Map
        ? Map<String, dynamic>.from(rawModelOutput)
        : rawModelOutput is String && rawModelOutput.isNotEmpty
        ? <String, dynamic>{'raw': rawModelOutput}
        : null;

    return DiagnosisRecord(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString(),
      result: json['result']?.toString() ?? 'Sin resultado',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      status: json['status']?.toString(),
      imageUrl: json['image_url']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
      modelOutput: modelOutput,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    result,
    confidence,
    status,
    imageUrl,
    createdAt,
    updatedAt,
    modelOutput,
  ];
}
