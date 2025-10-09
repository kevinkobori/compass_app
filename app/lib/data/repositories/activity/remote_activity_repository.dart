// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:compass_app/data/repositories/activity/activity_repository.dart';
import 'package:compass_app/data/services/api/api_client.dart';
import 'package:compass_app/domain/models/activity/activity.dart';
import 'package:result_dart/result_dart.dart';

/// Remote data source for [Activity].
/// Implements basic local caching.
/// See: https://docs.flutter.dev/get-started/fwe/local-caching
class RemoteActivityRepository implements ActivityRepository {
  RemoteActivityRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  final Map<String, List<Activity>> _cachedData = {};

  @override
  Future<Result<List<Activity>>> getByDestination(String ref) async {
    if (!_cachedData.containsKey(ref)) {
      // No cached data, request activities
      final result = await _apiClient.getActivityByDestination(ref);
      if (result.isSuccess()) {
        _cachedData[ref] = result.getOrThrow();
      }
      return result;
    } else {
      // Return cached data if available
      return Success(_cachedData[ref]!);
    }
  }
}
