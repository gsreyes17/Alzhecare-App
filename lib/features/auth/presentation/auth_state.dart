import 'package:equatable/equatable.dart';

import '../../../core/models/user_session.dart';

enum AuthStatus { loading, unauthenticated, authenticated, failure }

class AuthState extends Equatable {
  const AuthState({required this.status, this.session, this.message});

  final AuthStatus status;
  final UserSession? session;
  final String? message;

  factory AuthState.initial() {
    return const AuthState(status: AuthStatus.loading);
  }

  AuthState copyWith({
    AuthStatus? status,
    UserSession? session,
    String? message,
  }) {
    return AuthState(
      status: status ?? this.status,
      session: session ?? this.session,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, session, message];
}
