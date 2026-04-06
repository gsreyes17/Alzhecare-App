class UsuarioBasico {
  final String id;
  final String username;
  final String nombre;
  final String apellido;
  final String email;

  UsuarioBasico({
    required this.id,
    required this.username,
    required this.nombre,
    required this.apellido,
    required this.email,
  });

  String get nombreCompleto => '$nombre $apellido'.trim();

  factory UsuarioBasico.fromJson(Map<String, dynamic> json) {
    return UsuarioBasico(
      id: (json['id'] ?? '').toString(),
      username: json['username'] as String? ?? '',
      nombre: json['nombre'] as String? ?? '',
      apellido: json['apellido'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }
}

class SolicitudVinculacion {
  final String id;
  final String doctorUserId;
  final String patientUserId;
  final String? doctorNombre;
  final String? patientNombre;
  final String estado;
  final DateTime createdAt;
  final DateTime updatedAt;

  SolicitudVinculacion({
    required this.id,
    required this.doctorUserId,
    required this.patientUserId,
    this.doctorNombre,
    this.patientNombre,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SolicitudVinculacion.fromJson(Map<String, dynamic> json) {
    return SolicitudVinculacion(
      id: (json['id'] ?? '').toString(),
      doctorUserId: (json['doctor_user_id'] ?? '').toString(),
      patientUserId: (json['patient_user_id'] ?? '').toString(),
      doctorNombre: json['doctor_nombre'] as String?,
      patientNombre: json['patient_nombre'] as String?,
      estado: (json['estado'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()) ?? DateTime.now(),
      updatedAt: DateTime.tryParse((json['updated_at'] ?? '').toString()) ?? DateTime.now(),
    );
  }
}

class CitaCoordinacion {
  final String id;
  final String doctorUserId;
  final String patientUserId;
  final String titulo;
  final DateTime fechaHora;
  final String descripcion;
  final String estado;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? doctorNombre;
  final String? patientNombre;

  CitaCoordinacion({
    required this.id,
    required this.doctorUserId,
    required this.patientUserId,
    required this.titulo,
    required this.fechaHora,
    required this.descripcion,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
    this.doctorNombre,
    this.patientNombre,
  });

  factory CitaCoordinacion.fromJson(Map<String, dynamic> json) {
    return CitaCoordinacion(
      id: (json['id'] ?? '').toString(),
      doctorUserId: (json['doctor_user_id'] ?? '').toString(),
      patientUserId: (json['patient_user_id'] ?? '').toString(),
      titulo: (json['titulo'] ?? '').toString(),
      fechaHora: DateTime.tryParse((json['fecha_hora'] ?? '').toString()) ?? DateTime.now(),
      descripcion: (json['descripcion'] ?? '').toString(),
      estado: (json['estado'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()) ?? DateTime.now(),
      updatedAt: DateTime.tryParse((json['updated_at'] ?? '').toString()) ?? DateTime.now(),
      doctorNombre: json['doctor_nombre'] as String?,
      patientNombre: json['patient_nombre'] as String?,
    );
  }
}

class NotificacionCoordinacion {
  final String id;
  final String userId;
  final String tipo;
  final String titulo;
  final String mensaje;
  final Map<String, dynamic> data;
  final bool leida;
  final DateTime createdAt;

  NotificacionCoordinacion({
    required this.id,
    required this.userId,
    required this.tipo,
    required this.titulo,
    required this.mensaje,
    required this.data,
    required this.leida,
    required this.createdAt,
  });

  factory NotificacionCoordinacion.fromJson(Map<String, dynamic> json) {
    return NotificacionCoordinacion(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      tipo: (json['tipo'] ?? '').toString(),
      titulo: (json['titulo'] ?? '').toString(),
      mensaje: (json['mensaje'] ?? '').toString(),
      data: Map<String, dynamic>.from(json['data'] as Map? ?? const {}),
      leida: json['leida'] as bool? ?? false,
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()) ?? DateTime.now(),
    );
  }
}
