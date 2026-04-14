import 'package:equatable/equatable.dart';

class BasicUser extends Equatable {
  const BasicUser({
    required this.id,
    required this.username,
    required this.name,
    required this.lastname,
    this.email,
  });

  final String id;
  final String username;
  final String name;
  final String lastname;
  final String? email;

  String get fullName => '$name $lastname'.trim();

  factory BasicUser.fromJson(Map<String, dynamic> json) {
    return BasicUser(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      lastname: json['lastname']?.toString() ?? '',
      email: json['email']?.toString(),
    );
  }

  @override
  List<Object?> get props => [id, username, name, lastname, email];
}
