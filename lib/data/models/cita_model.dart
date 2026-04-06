class CitaModel {
  final int id;
  final int pacienteId;
  final int medicoId;
  final int? hospitalId;
  final DateTime fechaHora;
  final String estado;
  final String? motivo;
  final String? notas;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? pacienteNombre;
  final String? pacienteApellido;
  final String? medicoNombre;
  final String? medicoApellido;
  final String? hospitalNombre;

  CitaModel({
    required this.id,
    required this.pacienteId,
    required this.medicoId,
    this.hospitalId,
    required this.fechaHora,
    required this.estado,
    this.motivo,
    this.notas,
    required this.createdAt,
    required this.updatedAt,
    this.pacienteNombre,
    this.pacienteApellido,
    this.medicoNombre,
    this.medicoApellido,
    this.hospitalNombre,
  });

  factory CitaModel.fromJson(Map<String, dynamic> json) {
    return CitaModel(
      id: json['id'],
      pacienteId: json['paciente_id'],
      medicoId: json['medico_id'],
      hospitalId: json['hospital_id'],
      fechaHora: DateTime.parse(json['fecha_hora']),
      estado: json['estado'],
      motivo: json['motivo'],
      notas: json['notas'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      pacienteNombre: json['paciente_nombre'],
      pacienteApellido: json['paciente_apellido'],
      medicoNombre: json['medico_nombre'],
      medicoApellido: json['medico_apellido'],
      hospitalNombre: json['hospital_nombre'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paciente_id': pacienteId,
      'medico_id': medicoId,
      'hospital_id': hospitalId,
      'fecha_hora': fechaHora.toIso8601String(),
      'estado': estado,
      'motivo': motivo,
      'notas': notas,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get pacienteNombreCompleto =>
      '${pacienteNombre ?? ''} ${pacienteApellido ?? ''}'.trim();

  String get medicoNombreCompleto =>
      '${medicoNombre ?? ''} ${medicoApellido ?? ''}'.trim();

  String get estadoFormatted {
    switch (estado) {
      case 'programada':
        return 'Programada';
      case 'completada':
        return 'Completada';
      case 'cancelada':
        return 'Cancelada';
      case 'reprogramada':
        return 'Reprogramada';
      default:
        return estado;
    }
  }
}

class CitaCreateRequest {
  final int pacienteId;
  final int medicoId;
  final int? hospitalId;
  final DateTime fechaHora;
  final String? motivo;
  final String? notas;

  CitaCreateRequest({
    required this.pacienteId,
    required this.medicoId,
    this.hospitalId,
    required this.fechaHora,
    this.motivo,
    this.notas,
  });

  Map<String, dynamic> toJson() {
    final map = {
      'paciente_id': pacienteId,
      'medico_id': medicoId,
      'fecha_hora': fechaHora.toIso8601String(),
    };

    if (hospitalId != null) map['hospital_id'] = hospitalId!;
    if (motivo != null) map['motivo'] = motivo!;
    if (notas != null) map['notas'] = notas!;

    return map;
  }
}

class CitaUpdateRequest {
  final DateTime? fechaHora;
  final int? hospitalId;
  final String? motivo;
  final String? notas;

  CitaUpdateRequest({
    this.fechaHora,
    this.hospitalId,
    this.motivo,
    this.notas,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};

    if (fechaHora != null) map['fecha_hora'] = fechaHora!.toIso8601String();
    if (hospitalId != null) map['hospital_id'] = hospitalId!;
    if (motivo != null) map['motivo'] = motivo!;
    if (notas != null) map['notas'] = notas!;

    return map;
  }
}

class CitaCambiarEstadoRequest {
  final String estado;
  final String? motivoCambio;

  CitaCambiarEstadoRequest({
    required this.estado,
    this.motivoCambio,
  });

  Map<String, dynamic> toJson() {
    final map = {'estado': estado};
    if (motivoCambio != null) map['motivo_cambio'] = motivoCambio!;
    return map;
  }
}

class MedicoModel {
  final int id;
  final String nombre;
  final String apellido;
  final String? especialidad;
  final String? cmp;
  final String? hospitalAfiliacion;

  MedicoModel({
    required this.id,
    required this.nombre,
    required this.apellido,
    this.especialidad,
    this.cmp,
    this.hospitalAfiliacion,
  });

  factory MedicoModel.fromJson(Map<String, dynamic> json) {
    return MedicoModel(
      id: json['id'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      especialidad: json['especialidad'],
      cmp: json['cmp'],
      hospitalAfiliacion: json['hospital_afiliacion'],
    );
  }

  String get nombreCompleto => '$nombre $apellido';
}

class HorarioDisponible {
  final String horaInicio;
  final String horaFin;
  final bool disponible;

  HorarioDisponible({
    required this.horaInicio,
    required this.horaFin,
    required this.disponible,
  });

  factory HorarioDisponible.fromJson(Map<String, dynamic> json) {
    return HorarioDisponible(
      horaInicio: json['hora_inicio'],
      horaFin: json['hora_fin'],
      disponible: json['disponible'],
    );
  }
}

class DisponibilidadResponse {
  final int medicoId;
  final String fecha;
  final List<HorarioDisponible> horarios;

  DisponibilidadResponse({
    required this.medicoId,
    required this.fecha,
    required this.horarios,
  });

  factory DisponibilidadResponse.fromJson(Map<String, dynamic> json) {
    return DisponibilidadResponse(
      medicoId: json['medico_id'],
      fecha: json['fecha'],
      horarios: (json['horarios'] as List)
          .map((h) => HorarioDisponible.fromJson(h))
          .toList(),
    );
  }
}

