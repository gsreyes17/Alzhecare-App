/// Modelos para el Dashboard del Admin
/// Estos modelos corresponden a los endpoints del backend de /api/dashboard

class EstadisticasGenerales {
  final int totalPacientesActivos;
  final int totalMedicosActivos;
  final int totalAdminsActivos;
  final int totalUsuariosActivos;
  final int citasProgramadas;
  final int citasCompletadas;
  final int citasCanceladas;
  final int totalDiagnosticos;
  final int totalHospitales;
  final int totalAsignaciones;

  EstadisticasGenerales({
    required this.totalPacientesActivos,
    required this.totalMedicosActivos,
    required this.totalAdminsActivos,
    required this.totalUsuariosActivos,
    required this.citasProgramadas,
    required this.citasCompletadas,
    required this.citasCanceladas,
    required this.totalDiagnosticos,
    required this.totalHospitales,
    required this.totalAsignaciones,
  });

  factory EstadisticasGenerales.fromJson(Map<String, dynamic> json) {
    return EstadisticasGenerales(
      totalPacientesActivos: json['total_pacientes_activos'] ?? 0,
      totalMedicosActivos: json['total_medicos_activos'] ?? 0,
      totalAdminsActivos: json['total_admins_activos'] ?? 0,
      totalUsuariosActivos: json['total_usuarios_activos'] ?? 0,
      citasProgramadas: json['citas_programadas'] ?? 0,
      citasCompletadas: json['citas_completadas'] ?? 0,
      citasCanceladas: json['citas_canceladas'] ?? 0,
      totalDiagnosticos: json['total_diagnosticos'] ?? 0,
      totalHospitales: json['total_hospitales'] ?? 0,
      totalAsignaciones: json['total_asignaciones'] ?? 0,
    );
  }

  // Getters compatibles con el código anterior
  int get totalUsuarios =>
      totalPacientesActivos + totalMedicosActivos + totalAdminsActivos;
  int get totalCitas => citasProgramadas + citasCompletadas + citasCanceladas;
  Map<String, int> get usuariosPorTipo => {
        'paciente': totalPacientesActivos,
        'medico': totalMedicosActivos,
        'admin': totalAdminsActivos,
      };
  Map<String, int> get citasPorEstado => {
        'programadas': citasProgramadas,
        'completadas': citasCompletadas,
        'canceladas': citasCanceladas,
      };
  int get diagnosticosUltimoMes => totalDiagnosticos; // Placeholder
}

class DiagnosticoPorClasificacion {
  final String? clasificacion;
  final String? clasificacionIngles;
  final int? cantidadDiagnosticos;
  final double? confianzaPromedio;
  final int? pacientesUnicos;

  DiagnosticoPorClasificacion({
    this.clasificacion,
    this.clasificacionIngles,
    this.cantidadDiagnosticos,
    this.confianzaPromedio,
    this.pacientesUnicos,
  });

  factory DiagnosticoPorClasificacion.fromJson(Map<String, dynamic> json) {
    return DiagnosticoPorClasificacion(
      clasificacion: json['clasificacion'],
      clasificacionIngles: json['clasificacion_ingles'],
      cantidadDiagnosticos: json['cantidad_diagnosticos'],
      confianzaPromedio: json['confianza_promedio'] != null
          ? (json['confianza_promedio'] as num).toDouble()
          : null,
      pacientesUnicos: json['pacientes_unicos'],
    );
  }

  // Getter compatible con el código anterior
  int? get cantidad => cantidadDiagnosticos;
}

class CitasPorHospital {
  final String? hospital;
  final String? ciudad;
  final int? totalCitas;
  final int? citasProgramadas;
  final int? citasCompletadas;
  final int? citasCanceladas;
  final int? citasReprogramadas;

  CitasPorHospital({
    this.hospital,
    this.ciudad,
    this.totalCitas,
    this.citasProgramadas,
    this.citasCompletadas,
    this.citasCanceladas,
    this.citasReprogramadas,
  });

  factory CitasPorHospital.fromJson(Map<String, dynamic> json) {
    return CitasPorHospital(
      hospital: json['hospital'],
      ciudad: json['ciudad'],
      totalCitas: json['total_citas'],
      citasProgramadas: json['citas_programadas'],
      citasCompletadas: json['citas_completadas'],
      citasCanceladas: json['citas_canceladas'],
      citasReprogramadas: json['citas_reprogramadas'],
    );
  }

  // Getters compatibles con el código anterior
  int? get programadas => citasProgramadas;
  int? get completadas => citasCompletadas;
  int? get canceladas => citasCanceladas;
}

class PacienteDetallado {
  final int? pacienteId;
  final String? nombre;
  final String? apellido;
  final DateTime? fechaNacimiento;
  final int? edad;
  final String? genero;
  final String? ciudad;
  final String? estadoAlzheimer;
  final String? username;
  final bool? usuarioActivo;
  final int? totalDiagnosticos;
  final int? totalCitas;
  final int? medicosAsignados;
  final DateTime? ultimoDiagnostico;
  final DateTime? ultimaCita;

  PacienteDetallado({
    this.pacienteId,
    this.nombre,
    this.apellido,
    this.fechaNacimiento,
    this.edad,
    this.genero,
    this.ciudad,
    this.estadoAlzheimer,
    this.username,
    this.usuarioActivo,
    this.totalDiagnosticos,
    this.totalCitas,
    this.medicosAsignados,
    this.ultimoDiagnostico,
    this.ultimaCita,
  });

  factory PacienteDetallado.fromJson(Map<String, dynamic> json) {
    return PacienteDetallado(
      pacienteId: json['paciente_id'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      fechaNacimiento: json['fecha_nacimiento'] != null
          ? DateTime.parse(json['fecha_nacimiento'])
          : null,
      edad: json['edad'],
      genero: json['genero'],
      ciudad: json['ciudad'],
      estadoAlzheimer: json['estado_alzheimer'],
      username: json['username'],
      usuarioActivo: json['usuario_activo'],
      totalDiagnosticos: json['total_diagnosticos'],
      totalCitas: json['total_citas'],
      medicosAsignados: json['medicos_asignados'],
      ultimoDiagnostico: json['ultimo_diagnostico'] != null
          ? DateTime.parse(json['ultimo_diagnostico'])
          : null,
      ultimaCita: json['ultima_cita'] != null
          ? DateTime.parse(json['ultima_cita'])
          : null,
    );
  }

  // Getter compatible con el código anterior
  int? get id => pacienteId;
  DateTime? get ultimaActividad => ultimoDiagnostico ?? ultimaCita;
}

class MedicoEstadisticas {
  final int? medicoId;
  final String? nombre;
  final String? apellido;
  final String? cmp;
  final String? especialidad;
  final String? hospitalAfiliacion;
  final String? username;
  final bool? usuarioActivo;
  final int? totalCitas;
  final int? citasCompletadas;
  final int? citasProgramadas;
  final int? pacientesAsignados;
  final DateTime? ultimaCita;
  final DateTime? proximaCita;

  MedicoEstadisticas({
    this.medicoId,
    this.nombre,
    this.apellido,
    this.cmp,
    this.especialidad,
    this.hospitalAfiliacion,
    this.username,
    this.usuarioActivo,
    this.totalCitas,
    this.citasCompletadas,
    this.citasProgramadas,
    this.pacientesAsignados,
    this.ultimaCita,
    this.proximaCita,
  });

  factory MedicoEstadisticas.fromJson(Map<String, dynamic> json) {
    return MedicoEstadisticas(
      medicoId: json['medico_id'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      cmp: json['cmp'],
      especialidad: json['especialidad'],
      hospitalAfiliacion: json['hospital_afiliacion'],
      username: json['username'],
      usuarioActivo: json['usuario_activo'],
      totalCitas: json['total_citas'],
      citasCompletadas: json['citas_completadas'],
      citasProgramadas: json['citas_programadas'],
      pacientesAsignados: json['pacientes_asignados'],
      ultimaCita: json['ultima_cita'] != null
          ? DateTime.parse(json['ultima_cita'])
          : null,
      proximaCita: json['proxima_cita'] != null
          ? DateTime.parse(json['proxima_cita'])
          : null,
    );
  }

  // Getter compatible con el código anterior
  int? get id => medicoId;
}

class ActividadReciente {
  final String? tipoEvento;
  final int? eventoId;
  final int? usuarioId;
  final String? detalle;
  final DateTime? fechaEvento;

  ActividadReciente({
    this.tipoEvento,
    this.eventoId,
    this.usuarioId,
    this.detalle,
    this.fechaEvento,
  });

  factory ActividadReciente.fromJson(Map<String, dynamic> json) {
    return ActividadReciente(
      tipoEvento: json['tipo_evento'],
      eventoId: json['evento_id'],
      usuarioId: json['usuario_id'],
      detalle: json['detalle'],
      fechaEvento: json['fecha_evento'] != null
          ? DateTime.parse(json['fecha_evento'])
          : null,
    );
  }

  // Getters compatibles con el código anterior
  String? get tipo => tipoEvento;
  String? get descripcion => detalle;
  DateTime? get fecha => fechaEvento;
  Map<String, dynamic>? get detalles => {
        'evento_id': eventoId,
        'usuario_id': usuarioId,
      };
}

class DiagnosticosPorMes {
  final DateTime? mes;
  final int totalDiagnosticos;
  final int pacientesUnicos;
  final double? confianzaPromedio;
  final int sinDemencia;
  final int demenciaMuyLeve;
  final int demenciaLeve;
  final int demenciaModerada;

  DiagnosticosPorMes({
    this.mes,
    required this.totalDiagnosticos,
    required this.pacientesUnicos,
    this.confianzaPromedio,
    required this.sinDemencia,
    required this.demenciaMuyLeve,
    required this.demenciaLeve,
    required this.demenciaModerada,
  });

  factory DiagnosticosPorMes.fromJson(Map<String, dynamic> json) {
    return DiagnosticosPorMes(
      mes: json['mes'] != null ? DateTime.parse(json['mes']) : null,
      totalDiagnosticos: json['total_diagnosticos'] ?? 0,
      pacientesUnicos: json['pacientes_unicos'] ?? 0,
      confianzaPromedio: json['confianza_promedio'] != null
          ? (json['confianza_promedio'] as num).toDouble()
          : null,
      sinDemencia: json['sin_demencia'] ?? 0,
      demenciaMuyLeve: json['demencia_muy_leve'] ?? 0,
      demenciaLeve: json['demencia_leve'] ?? 0,
      demenciaModerada: json['demencia_moderada'] ?? 0,
    );
  }

  // Getters compatibles con el código anterior
  Map<String, int> get porClasificacion => {
        'Sin demencia': sinDemencia,
        'Demencia muy leve': demenciaMuyLeve,
        'Demencia leve': demenciaLeve,
        'Demencia moderada': demenciaModerada,
      };
}

class DashboardCompleto {
  final EstadisticasGenerales estadisticasGenerales;
  final List<DiagnosticoPorClasificacion> diagnosticosPorClasificacion;
  final List<CitasPorHospital> citasPorHospital;
  final List<PacienteDetallado> pacientesDestacados;
  final List<MedicoEstadisticas> medicosEstadisticas;
  final List<ActividadReciente> actividadReciente;
  final List<DiagnosticosPorMes> tendenciasMensuales;

  DashboardCompleto({
    required this.estadisticasGenerales,
    required this.diagnosticosPorClasificacion,
    required this.citasPorHospital,
    required this.pacientesDestacados,
    required this.medicosEstadisticas,
    required this.actividadReciente,
    required this.tendenciasMensuales,
  });

  factory DashboardCompleto.fromJson(Map<String, dynamic> json) {
    return DashboardCompleto(
      estadisticasGenerales:
          EstadisticasGenerales.fromJson(json['estadisticas_generales'] ?? {}),
      diagnosticosPorClasificacion:
          (json['diagnosticos_clasificacion'] as List?)
                  ?.map((e) => DiagnosticoPorClasificacion.fromJson(e))
                  .toList() ??
              [],
      citasPorHospital: (json['citas_por_hospital'] as List?)
              ?.map((e) => CitasPorHospital.fromJson(e))
              .toList() ??
          [],
      pacientesDestacados: (json['pacientes_destacados'] as List?)
              ?.map((e) => PacienteDetallado.fromJson(e))
              .toList() ??
          [],
      medicosEstadisticas: (json['medicos_destacados'] as List?)
              ?.map((e) => MedicoEstadisticas.fromJson(e))
              .toList() ??
          [],
      actividadReciente: (json['actividad_reciente'] as List?)
              ?.map((e) => ActividadReciente.fromJson(e))
              .toList() ??
          [],
      tendenciasMensuales: (json['diagnosticos_por_mes'] as List?)
              ?.map((e) => DiagnosticosPorMes.fromJson(e))
              .toList() ??
          [],
    );
  }
}
