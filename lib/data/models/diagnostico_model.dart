class AnalisisResponse {
  final String id;
  final String resultado;
  final double confianza;
  final String claseOriginal;
  final String imagenOriginalUrl;
  final DateTime createdAt;

  AnalisisResponse({
    required this.id,
    required this.resultado,
    required this.confianza,
    required this.claseOriginal,
    required this.imagenOriginalUrl,
    required this.createdAt,
  });

  factory AnalisisResponse.fromJson(Map<String, dynamic> json) {
    return AnalisisResponse(
      id: (json['id'] ?? '').toString(),
      resultado: json['resultado'] as String? ?? 'Sin resultado',
      confianza: (json['confianza'] as num?)?.toDouble() ?? 0.0,
      claseOriginal: json['clase_original'] as String? ?? '',
      imagenOriginalUrl: json['imagen_original_url'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  String get confianzaTexto => '${(confianza * 100).toStringAsFixed(1)}%';
}

class DiagnosticoResponse extends AnalisisResponse {
  final String userId;
  final String estado;

  DiagnosticoResponse({
    required super.id,
    required super.resultado,
    required super.confianza,
    required super.claseOriginal,
    required super.imagenOriginalUrl,
    required super.createdAt,
    required this.userId,
    required this.estado,
  });

  factory DiagnosticoResponse.fromJson(Map<String, dynamic> json) {
    return DiagnosticoResponse(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      resultado: json['resultado'] as String? ?? 'Sin resultado',
      confianza: (json['confianza'] as num?)?.toDouble() ?? 0.0,
      claseOriginal: json['clase_original'] as String? ?? '',
      estado: json['estado'] as String? ?? 'completado',
      imagenOriginalUrl: json['imagen_original_url'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class Diagnostico extends DiagnosticoResponse {
  Diagnostico({
    required super.id,
    required super.userId,
    required super.resultado,
    required super.confianza,
    required super.claseOriginal,
    required super.estado,
    required super.imagenOriginalUrl,
    required super.createdAt,
  });

  factory Diagnostico.fromJson(Map<String, dynamic> json) {
    return Diagnostico(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      resultado: json['resultado'] as String? ?? 'Sin resultado',
      confianza: (json['confianza'] as num?)?.toDouble() ?? 0.0,
      claseOriginal: json['clase_original'] as String? ?? '',
      estado: json['estado'] as String? ?? 'completado',
      imagenOriginalUrl: json['imagen_original_url'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  String get fechaFormateada {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  String get horaFormateada {
    return '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  String get pacienteId => userId;
  String get imagenProcesadaUrl => '';
}

class DiagnosticoDetalle extends Diagnostico {
  final Map<String, dynamic> datosRoboflow;

  DiagnosticoDetalle({
    required super.id,
    required super.userId,
    required super.resultado,
    required super.confianza,
    required super.claseOriginal,
    required super.estado,
    required super.imagenOriginalUrl,
    required super.createdAt,
    required this.datosRoboflow,
  });

  factory DiagnosticoDetalle.fromJson(Map<String, dynamic> json) {
    return DiagnosticoDetalle(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      resultado: json['resultado'] as String? ?? 'Sin resultado',
      confianza: (json['confianza'] as num?)?.toDouble() ?? 0.0,
      claseOriginal: json['clase_original'] as String? ?? '',
      estado: json['estado'] as String? ?? 'completado',
      imagenOriginalUrl: json['imagen_original_url'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      datosRoboflow: Map<String, dynamic>.from(json['datos_roboflow'] as Map? ?? const {}),
    );
  }
}

class HistorialResponse {
  final List<Diagnostico> diagnosticos;
  final int total;

  HistorialResponse({required this.diagnosticos, required this.total});

  factory HistorialResponse.fromJson(Map<String, dynamic> json) {
    return HistorialResponse(
      diagnosticos: ((json['diagnosticos'] as List?) ?? const [])
          .map((item) => Diagnostico.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      total: json['total'] as int? ?? 0,
    );
  }
}
