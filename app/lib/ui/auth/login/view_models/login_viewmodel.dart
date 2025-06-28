// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:logging/logging.dart';

import '../../../../data/repositories/auth/auth_repository.dart';
import 'package:result_dart/result_dart.dart';
import 'package:result_command/result_command.dart';

class LoginViewModel {
  LoginViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository {
    login = Command1<Unit, (String email, String password)>(_login);
  }

  final AuthRepository _authRepository;
  final _log = Logger('LoginViewModel');

  late Command1 login;

  Future<Result<Unit>> _login((String, String) credentials) async {
    final (email, password) = credentials;
    final result = await _authRepository.login(
      email: email,
      password: password,
    );
    if (result.isError()) {
      _log.warning('Login failed! ${result.exceptionOrNull()}');
    }
    return result;
  }
}
