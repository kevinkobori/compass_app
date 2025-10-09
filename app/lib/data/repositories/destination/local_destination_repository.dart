// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:compass_app/data/repositories/destination/destination_repository.dart';
import 'package:compass_app/data/services/local/local_data_service.dart';
import 'package:compass_app/domain/models/destination/destination.dart';
import 'package:result_dart/result_dart.dart';

/// Local implementation of DestinationRepository
/// Uses data from assets folder
class LocalDestinationRepository implements DestinationRepository {
  LocalDestinationRepository({required LocalDataService localDataService})
    : _localDataService = localDataService;

  final LocalDataService _localDataService;

  /// Obtain list of destinations from local assets
  @override
  Future<Result<List<Destination>>> getDestinations() async {
    try {
      return Success(await _localDataService.getDestinations());
    } on Exception catch (error) {
      return Failure(error);
    }
  }
}
