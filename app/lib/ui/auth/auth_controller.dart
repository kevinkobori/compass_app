import 'dart:async';

import 'package:compass_app/config/dependencies.dart';
import 'package:compass_app/data/repositories/auth/auth_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:result_dart/result_dart.dart';

/// Notifier that exposes the authentication status and operations.
class AuthController extends AsyncNotifier<bool> {
  late final AuthRepository _authRepository;
  final _authStateController = StreamController<bool>.broadcast();

  Stream<bool> get stream => _authStateController.stream;

  @override
  FutureOr<bool> build() async {
    ref.onDispose(_authStateController.close);

    _authRepository = ref.read(authRepositoryProvider);
    final isAuth = await _authRepository.isAuthenticated;
    _authStateController.add(isAuth);
    return isAuth;
  }

  Future<Result<Unit>> login({
    required String email,
    required String password,
  }) async {
    final result = await _authRepository.login(
      email: email,
      password: password,
    );
    final isAuth = await _authRepository.isAuthenticated;
    _authStateController.add(isAuth);
    state = AsyncData(isAuth);
    return result;
  }

  Future<Result<Unit>> logout() async {
    final result = await _authRepository.logout();
    final isAuth = await _authRepository.isAuthenticated;
    _authStateController.add(isAuth);
    state = AsyncData(isAuth);
    return result;
  }
}

/// Provider for the [AuthController].
final authControllerProvider = AsyncNotifierProvider<AuthController, bool>(
  AuthController.new,
);
