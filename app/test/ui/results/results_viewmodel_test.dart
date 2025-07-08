// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:compass_app/config/dependencies.dart';
import 'package:compass_app/domain/models/itinerary_config/itinerary_config.dart';
import 'package:compass_app/ui/results/view_models/results_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../testing/fakes/repositories/fake_destination_repository.dart';
import '../../../testing/fakes/repositories/fake_itinerary_config_repository.dart';

void main() {
  group('ResultsViewModel tests', () {
    late ProviderContainer container;
    late ResultsViewModel viewModel;

    setUp(() {
      container = ProviderContainer(overrides: [
        destinationRepositoryProvider.overrideWithValue(
          FakeDestinationRepository(),
        ),
        itineraryConfigRepositoryProvider.overrideWith(
          (ref) => FakeItineraryConfigRepository(
            itineraryConfig: ItineraryConfig(
              continent: 'Europe',
              startDate: DateTime(2024),
              endDate: DateTime(2024, 01, 31),
              guests: 2,
            ),
          ),
        ),
      ]);
      viewModel = container.read(resultsViewModelProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('should load items', () {
      expect(viewModel.destinations.length, 2);
    });
  });
}
