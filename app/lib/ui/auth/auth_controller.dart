import 'dart:async';

import 'package:compass_app/config/dependencies.dart';
import 'package:compass_app/data/repositories/auth/auth_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:result_dart/result_dart.dart';

/// Notifier that exposes the authentication status and operations.
class AuthController extends AsyncNotifier<bool> {
  late final AuthRepository _authRepository;

  @override
  FutureOr<bool> build() async {
    _authRepository = ref.read(authRepositoryProvider);
    return _authRepository.isAuthenticated;
  }

  /// Perform login and update the authentication state.
  Future<Result<Unit>> login({required String email, required String password}) async {
    final result = await _authRepository.login(email: email, password: password);
    state = AsyncData(await _authRepository.isAuthenticated);
    return result;
  }

  /// Perform logout and update the authentication state.
  Future<Result<Unit>> logout() async {
    final result = await _authRepository.logout();
    state = AsyncData(await _authRepository.isAuthenticated);
    return result;
  }
}

/// Provider for the [AuthController].
final authControllerProvider =
    AsyncNotifierProvider<AuthController, bool>(AuthController.new);
