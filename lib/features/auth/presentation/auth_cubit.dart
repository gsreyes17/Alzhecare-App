import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(AuthState.initial());

  final AuthRepository _authRepository;

  Future<void> bootstrap() async {
    try {
      final session = await _authRepository.bootstrap();
      emit(AuthState(status: AuthStatus.authenticated, session: session));
    } catch (_) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading, message: null));
    try {
      final session = await _authRepository.login(
        username: username,
        password: password,
      );
      emit(AuthState(status: AuthStatus.authenticated, session: session));
    } catch (error) {
      emit(
        AuthState(
          status: AuthStatus.failure,
          message: _messageFromError(error),
        ),
      );
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> register({
    required String username,
    required String password,
    required String name,
    required String lastname,
    required String email,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading, message: null));
    try {
      final session = await _authRepository.register(
        username: username,
        password: password,
        name: name,
        lastname: lastname,
        email: email,
      );
      emit(AuthState(status: AuthStatus.authenticated, session: session));
    } catch (error) {
      emit(
        AuthState(
          status: AuthStatus.failure,
          message: _messageFromError(error),
        ),
      );
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  Future<void> updateProfile({
    String? name,
    String? lastname,
    String? email,
  }) async {
    final currentSession = state.session;
    if (currentSession == null) {
      return;
    }

    try {
      final updatedSession = await _authRepository.updateProfile(
        currentSession: currentSession,
        name: name,
        lastname: lastname,
        email: email,
      );
      emit(
        AuthState(
          status: AuthStatus.authenticated,
          session: updatedSession,
          message: 'Perfil actualizado correctamente',
        ),
      );
    } catch (error) {
      emit(state.copyWith(message: _messageFromError(error)));
    }
  }

  Future<void> changePassword({required String newPassword}) async {
    final currentSession = state.session;
    if (currentSession == null) {
      return;
    }

    try {
      final updatedSession = await _authRepository.changePassword(
        currentSession: currentSession,
        newPassword: newPassword,
      );
      emit(
        AuthState(
          status: AuthStatus.authenticated,
          session: updatedSession,
          message: 'Contraseña actualizada correctamente',
        ),
      );
    } catch (error) {
      emit(state.copyWith(message: _messageFromError(error)));
    }
  }

  Future<void> uploadProfilePhoto({
    required Uint8List bytes,
    required String filename,
  }) async {
    final currentSession = state.session;
    if (currentSession == null) {
      return;
    }

    try {
      final updatedSession = await _authRepository.uploadProfilePhoto(
        currentSession: currentSession,
        bytes: bytes,
        filename: filename,
      );
      emit(
        AuthState(
          status: AuthStatus.authenticated,
          session: updatedSession,
          message: 'Foto de perfil actualizada',
        ),
      );
    } catch (error) {
      emit(state.copyWith(message: _messageFromError(error)));
    }
  }

  String _messageFromError(Object error) {
    final message = error.toString();
    if (message.startsWith('ApiException')) {
      return message.replaceFirst(RegExp(r'^ApiException\(\d+\):\s*'), '');
    }
    if (message.contains('StateError')) {
      return message.replaceFirst('Bad state: ', '');
    }
    return 'No fue posible completar la operación';
  }
}
