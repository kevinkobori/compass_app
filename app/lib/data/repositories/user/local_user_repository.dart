// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:compass_app/data/repositories/user/user_repository.dart';
import 'package:compass_app/data/services/local/local_data_service.dart';
import 'package:compass_app/domain/models/user/user.dart';
import 'package:result_dart/result_dart.dart';

class LocalUserRepository implements UserRepository {
  LocalUserRepository({required LocalDataService localDataService})
    : _localDataService = localDataService;

  final LocalDataService _localDataService;

  @override
  Future<Result<User>> getUser() async {
    return Success(_localDataService.getUser());
  }
}
