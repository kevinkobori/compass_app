// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:compass_app/domain/models/activity/activity.dart';
import 'package:compass_app/domain/models/destination/destination.dart'
    show Destination;
import 'package:result_dart/result_dart.dart';

/// Data source for activities.
mixin ActivityRepository {
  /// Get activities by [Destination] ref.
  Future<Result<List<Activity>>> getByDestination(String ref);
}
