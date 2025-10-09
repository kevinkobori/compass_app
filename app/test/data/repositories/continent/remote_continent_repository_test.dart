// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:compass_app/data/repositories/continent/continent_repository.dart';
import 'package:compass_app/data/repositories/continent/remote_continent_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:result_dart/result_dart.dart';

import '../../../../testing/fakes/services/fake_api_client.dart';

void main() {
  group('RemoteContinentRepository tests', () {
    late FakeApiClient apiClient;
    late ContinentRepository repository;

    setUp(() {
      apiClient = FakeApiClient();
      repository = RemoteContinentRepository(apiClient: apiClient);
    });

    test('should get continents', () async {
      final result = await repository.getContinents();
      expect(result, isA<Success>());

      final list = result.getOrThrow();
      expect(list.length, 3);

      final destination = list.first;
      expect(destination.name, 'CONTINENT');

      // Only one request happened
      expect(apiClient.requestCount, 1);
    });

    test('should get continents from cache', () async {
      // Request continents once
      var result = await repository.getContinents();
      expect(result, isA<Success>());

      // Request continents another time
      result = await repository.getContinents();
      expect(result, isA<Success>());

      // Only one request happened
      expect(apiClient.requestCount, 1);
    });
  });
}
