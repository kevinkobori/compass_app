// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:compass_app/data/repositories/continent/continent_repository.dart';
import 'package:compass_app/data/services/local/local_data_service.dart';
import 'package:compass_app/domain/models/continent/continent.dart';
import 'package:result_dart/result_dart.dart';

/// Local data source with all possible continents.
class LocalContinentRepository implements ContinentRepository {
  LocalContinentRepository({required LocalDataService localDataService})
    : _localDataService = localDataService;

  final LocalDataService _localDataService;

  @override
  Future<Result<List<Continent>>> getContinents() async {
    return Future.value(Success(_localDataService.getContinents()));
  }
}
