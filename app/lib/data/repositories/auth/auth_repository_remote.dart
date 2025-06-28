// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:logging/logging.dart';

import 'package:result_dart/result_dart.dart';
import '../../services/api/api_client.dart';
import '../../services/api/auth_api_client.dart';
import '../../services/api/model/login_request/login_request.dart';
import '../../services/api/model/login_response/login_response.dart';
import '../../services/shared_preferences_service.dart';
import 'auth_repository.dart';

class AuthRepositoryRemote extends AuthRepository {
  AuthRepositoryRemote({
    required ApiClient apiClient,
    required AuthApiClient authApiClient,
    required SharedPreferencesService sharedPreferencesService,
  }) : _apiClient = apiClient,
       _authApiClient = authApiClient,
       _sharedPreferencesService = sharedPreferencesService {
    _apiClient.authHeaderProvider = _authHeaderProvider;
  }

  final AuthApiClient _authApiClient;
  final ApiClient _apiClient;
  final SharedPreferencesService _sharedPreferencesService;

  bool? _isAuthenticated;
  String? _authToken;
  final _log = Logger('AuthRepositoryRemote');

  /// Fetch token from shared preferences
  Future<void> _fetch() async {
    final result = await _sharedPreferencesService.fetchToken();
    result.fold(
      (token) {
        _authToken = token;
        _isAuthenticated = true;
      },
      (error) {
        _authToken = null;
        _isAuthenticated = false;
        _log.severe('Failed to fetch Token from SharedPreferences', error);
      },
    );
  }

  @override
  Future<bool> get isAuthenticated async {
    // Status is cached
    if (_isAuthenticated != null) {
      return _isAuthenticated!;
    }
    // No status cached, fetch from storage
    await _fetch();
    return _isAuthenticated ?? false;
  }

  @override
  Future<Result<Unit>> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _authApiClient.login(
        LoginRequest(email: email, password: password),
      );

      if (result.isSuccess()) {
        final loginResponse = result.getOrThrow();
        _log.info('User logged in');
        _isAuthenticated = true;
        _authToken = loginResponse.token;
        // Chama método async e retorna
        return await _sharedPreferencesService.saveToken(loginResponse.token);
      } else {
        final error = result.exceptionOrNull();
        _log.warning('Error logging in: $error');
        return Failure(error ?? Exception('Unknown error'));
      }
    } finally {
      notifyListeners();
    }
  }

  @override
  Future<Result<Unit>> logout() async {
    _log.info('User logged out');
    try {
      // Limpa o token salvo
      final result = await _sharedPreferencesService.saveToken(
        null,
      );
      if (result.isError()) {
        _log.severe(
          'Failed to clear stored auth token: ${result.exceptionOrNull()}',
        );
      }
      // Limpa o token no ApiClient
      _authToken = null;
      _isAuthenticated = false;
      return result;
    } finally {
      notifyListeners();
    }
  }

  String? _authHeaderProvider() =>
      _authToken != null ? 'Bearer $_authToken' : null;
}
