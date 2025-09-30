// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:compass_app/data/repositories/continent/continent_repository.dart';
import 'package:compass_app/domain/models/continent/continent.dart';
import 'package:flutter/foundation.dart';
import 'package:result_dart/result_dart.dart';

class FakeContinentRepository implements ContinentRepository {
  @override
  Future<Result<List<Continent>>> getContinents() {
    return SynchronousFuture(
      const Success([
        Continent(name: 'CONTINENT', imageUrl: 'URL'),
        Continent(name: 'CONTINENT2', imageUrl: 'URL'),
        Continent(name: 'CONTINENT3', imageUrl: 'URL'),
      ]),
    );
  }
}
