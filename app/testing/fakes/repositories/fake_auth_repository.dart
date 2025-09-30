// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:compass_app/data/repositories/auth/auth_repository.dart';
import 'package:result_dart/result_dart.dart';

class FakeAuthRepository extends AuthRepository {
  String? token;

  @override
  Future<bool> get isAuthenticated async => token != null;

  @override
  Future<Result<Unit>> login({
    required String email,
    required String password,
  }) async {
    token = 'TOKEN';
    return const Success(unit);
  }

  @override
  Future<Result<Unit>> logout() async {
    token = null;
    return const Success(unit);
  }
}
