import 'package:equatable/equatable.dart';

import 'app_user.dart';

class UserSession extends Equatable {
  const UserSession({required this.accessToken, required this.user});

  final String accessToken;
  final AppUser user;

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      accessToken:
          json['accessToken']?.toString() ??
          json['access_token']?.toString() ??
          '',
      user: AppUser.fromJson(Map<String, dynamic>.from(json['user'] as Map)),
    );
  }

  Map<String, dynamic> toJson() {
    return {'accessToken': accessToken, 'user': user.toJson()};
  }

  @override
  List<Object?> get props => [accessToken, user];
}
