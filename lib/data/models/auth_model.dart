import 'package:flutter/foundation.dart';

@immutable
class UserRole {
  static const String patient = 'patient';
  static const String doctor = 'doctor';
  static const String admin = 'admin';
}

extension UserRoleLabel on String {
  String get roleLabel {
    switch (this) {
      case UserRole.patient:
        return 'Paciente';
      case UserRole.doctor:
        return 'Doctor';
      case UserRole.admin:
        return 'Admin';
      default:
        return this;
    }
  }
}

class AuthResponse {
  final String accessToken;
  final String tokenType;

  AuthResponse({required this.accessToken, required this.tokenType});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String? ?? 'bearer',
    );
  }
}

class LoginRequest {
  final String username;
  final String password;

  LoginRequest({required this.username, required this.password});

  Map<String, dynamic> toJson() {
    return {'username': username, 'password': password};
  }
}

class RegisterRequest {
  final String username;
  final String password;
  final String nombre;
  final String apellido;
  final String? email;
  final String? tipoUsuario;
  final String? telefono;
  final String? fechaNacimiento;
  final String? genero;
  final String? numeroIdentidad;
  final String? direccion;
  final String? ciudad;
  final String? estadoAlzheimer;
  final String? relacionPaciente;
  final String? cmp;
  final String? especialidad;
  final String? hospitalAfiliacion;
  final String? nivelAcceso;
  final String? permisos;

  RegisterRequest({
    required this.username,
    required this.password,
    required this.nombre,
    required this.apellido,
    this.email,
    this.tipoUsuario,
    this.telefono,
    this.fechaNacimiento,
    this.genero,
    this.numeroIdentidad,
    this.direccion,
    this.ciudad,
    this.estadoAlzheimer,
    this.relacionPaciente,
    this.cmp,
    this.especialidad,
    this.hospitalAfiliacion,
    this.nivelAcceso,
    this.permisos,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'username': username,
      'password': password,
      'nombre': nombre,
      'apellido': apellido,
    };

    if (email != null && email!.isNotEmpty) {
      map['email'] = email;
    }

    return map;
  }
}

class AdminCreateUserRequest extends RegisterRequest {
  final String role;

  AdminCreateUserRequest({
    required super.username,
    required super.password,
    required super.nombre,
    required super.apellido,
    super.email,
    this.role = UserRole.doctor,
  });

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    map['role'] = role;
    return map;
  }
}

class AdminUpdateUserRequest {
  final String? nombre;
  final String? apellido;
  final String? password;
  final bool? estado;
  final String? role;

  AdminUpdateUserRequest({
    this.nombre,
    this.apellido,
    this.password,
    this.estado,
    this.role,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (nombre != null) map['nombre'] = nombre;
    if (apellido != null) map['apellido'] = apellido;
    if (password != null) map['password'] = password;
    if (estado != null) map['estado'] = estado;
    if (role != null) map['role'] = role;
    return map;
  }
}

class UserProfileUpdateRequest {
  final String? nombre;
  final String? apellido;
  final String? email;
  final String? password;

  UserProfileUpdateRequest({this.nombre, this.apellido, this.email, this.password});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (nombre != null) map['nombre'] = nombre;
    if (apellido != null) map['apellido'] = apellido;
    if (email != null) map['email'] = email;
    if (password != null) map['password'] = password;
    return map;
  }
}

class Token {
  final String accessToken;
  final String tokenType;

  Token({required this.accessToken, this.tokenType = 'bearer'});

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String? ?? 'bearer',
    );
  }
}

class UserResponse {
  final String id;
  final String username;
  final String nombre;
  final String apellido;
  final String email;
  final String role;
  final bool estado;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserResponse({
    required this.id,
    required this.username,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.role,
    required this.estado,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: (json['id'] ?? '').toString(),
      username: json['username'] as String? ?? '',
      nombre: json['nombre'] as String? ?? '',
      apellido: json['apellido'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? UserRole.patient,
      estado: json['estado'] as bool? ?? true,
      profileImageUrl: json['profile_image_url'] as String?,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  String get tipoUsuario => role;
  int? get pacienteId => null;
  int? get medicoId => null;
  int? get adminId => null;
  String get roleLabel => role.roleLabel;
}

class UsersListResponse {
  final List<UserResponse> users;
  final int total;

  UsersListResponse({required this.users, required this.total});

  factory UsersListResponse.fromJson(Map<String, dynamic> json) {
    return UsersListResponse(
      users: ((json['users'] as List?) ?? const [])
          .map((item) => UserResponse.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      total: json['total'] as int? ?? 0,
    );
  }
}
