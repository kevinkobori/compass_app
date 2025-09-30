// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:compass_app/data/repositories/destination/destination_repository.dart';
import 'package:compass_app/domain/models/destination/destination.dart';
import 'package:flutter/foundation.dart';
import 'package:result_dart/result_dart.dart';

import '../../models/destination.dart';

class FakeDestinationRepository implements DestinationRepository {
  @override
  Future<Result<List<Destination>>> getDestinations() {
    return SynchronousFuture(const Success([kDestination1, kDestination2]));
  }
}
