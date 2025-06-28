// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:compass_app/data/repositories/activity/activity_repository.dart';
import 'package:compass_app/data/services/local/local_data_service.dart';
import 'package:compass_app/domain/models/activity/activity.dart';
import 'package:result_dart/result_dart.dart';

/// Local implementation of ActivityRepository
/// Uses data from assets folder
class ActivityRepositoryLocal implements ActivityRepository {
  ActivityRepositoryLocal({required LocalDataService localDataService})
    : _localDataService = localDataService;

  final LocalDataService _localDataService;

  @override
  Future<Result<List<Activity>>> getByDestination(String ref) async {
    try {
      final activities =
          (await _localDataService.getActivities())
              .where((activity) => activity.destinationRef == ref)
              .toList();

      return Success(activities);
    } on Exception catch (error) {
      return Failure(error);
    }
  }
}
