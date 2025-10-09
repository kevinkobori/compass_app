// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:compass_app/data/repositories/auth/auth_repository.dart';
import 'package:result_dart/result_dart.dart';

class DevAuthRepository extends AuthRepository {
  /// User is always authenticated in dev scenarios
  @override
  Future<bool> get isAuthenticated => Future.value(true);

  /// Login is always successful in dev scenarios
  @override
  Future<Result<Unit>> login({
    required String email,
    required String password,
  }) async {
    return const Success(unit);
  }

  /// Logout is always successful in dev scenarios
  @override
  Future<Result<Unit>> logout() async {
    return const Success(unit);
  }
}
