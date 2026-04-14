import 'package:equatable/equatable.dart';

enum UserRole { paciente, doctor, admin }

extension UserRoleX on UserRole {
  String get apiValue => switch (this) {
    UserRole.paciente => 'paciente',
    UserRole.doctor => 'doctor',
    UserRole.admin => 'admin',
  };

  String get label => switch (this) {
    UserRole.paciente => 'Paciente',
    UserRole.doctor => 'Doctor',
    UserRole.admin => 'Administrador',
  };

  static UserRole fromApiValue(String? value) {
    return switch (value) {
      'doctor' => UserRole.doctor,
      'admin' => UserRole.admin,
      _ => UserRole.paciente,
    };
  }
}

class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.username,
    required this.name,
    required this.lastname,
    required this.email,
    required this.role,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.profileImageUrl,
  });

  final String id;
  final String username;
  final String name;
  final String lastname;
  final String email;
  final UserRole role;
  final bool status;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get fullName => '$name $lastname'.trim();

  AppUser copyWith({
    String? id,
    String? username,
    String? name,
    String? lastname,
    String? email,
    UserRole? role,
    bool? status,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      username: username ?? this.username,
      name: name ?? this.name,
      lastname: lastname ?? this.lastname,
      email: email ?? this.email,
      role: role ?? this.role,
      status: status ?? this.status,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      lastname: json['lastname']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: UserRoleX.fromApiValue(json['role']?.toString()),
      status: json['status'] == true,
      profileImageUrl: json['profile_image_url']?.toString(),
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'lastname': lastname,
      'email': email,
      'role': role.apiValue,
      'status': status,
      'profile_image_url': profileImageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    username,
    name,
    lastname,
    email,
    role,
    status,
    profileImageUrl,
    createdAt,
    updatedAt,
  ];
}
