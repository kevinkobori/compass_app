// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:compass_app/domain/models/user/user.dart';
import 'package:result_dart/result_dart.dart';

/// Data source for user related data
mixin UserRepository {
  /// Get current user
  Future<Result<User>> getUser();
}
