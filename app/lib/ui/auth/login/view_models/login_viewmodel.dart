// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:compass_app/ui/auth/auth_controller.dart';
import 'package:logging/logging.dart';
import 'package:result_command/result_command.dart';
import 'package:result_dart/result_dart.dart';

class LoginViewModel {
  LoginViewModel({required AuthController authController})
    : _authController = authController {
    login = Command1<Unit, (String email, String password)>(_login);
  }

  final AuthController _authController;
  final _log = Logger('LoginViewModel');

  late Command1<Object, dynamic> login;

  Future<Result<Unit>> _login((String, String) credentials) async {
    final (email, password) = credentials;
    final result = await _authController.login(
      email: email,
      password: password,
    );
    if (result.isError()) {
      _log.warning('Login failed! ${result.exceptionOrNull()}');
    }
    return result;
  }
}
