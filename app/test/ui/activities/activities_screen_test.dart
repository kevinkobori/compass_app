// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:compass_app/domain/models/itinerary_config/itinerary_config.dart';
import 'package:compass_app/ui/activities/view_models/activities_viewmodel.dart';
import 'package:compass_app/ui/activities/widgets/activities_screen.dart';
import 'package:compass_app/config/dependencies.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:compass_app/ui/activities/widgets/activity_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';

import '../../../testing/app.dart';
import '../../../testing/fakes/repositories/fake_activities_repository.dart';
import '../../../testing/fakes/repositories/fake_itinerary_config_repository.dart';
import '../../../testing/mocks.dart';

void main() {
  group('ResultsScreen widget tests', () {
    late ActivitiesViewModel viewModel;
    late MockGoRouter goRouter;
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(overrides: [
        activityRepositoryProvider.overrideWithValue(FakeActivityRepository()),
        itineraryConfigRepositoryProvider.overrideWith(
          (ref) => FakeItineraryConfigRepository(
            itineraryConfig: ItineraryConfig(
              continent: 'Europe',
              startDate: DateTime(2024),
              endDate: DateTime(2024, 01, 31),
              guests: 2,
              destination: 'DESTINATION',
            ),
          ),
        ),
      ]);
      viewModel = container.read(activitiesViewModelProvider.notifier);
      goRouter = MockGoRouter();
    });

    tearDown(() {
      container.dispose();
    });

    Future<void> loadScreen(WidgetTester tester) async {
      await testApp(
        tester,
        UncontrolledProviderScope(
          container: container,
          child: const ActivitiesScreen(),
        ),
        goRouter: goRouter,
      );
    }

    testWidgets('should load screen', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        // Executa o comando loadActivities antes de carregar o widget
        await viewModel.loadActivities.execute();
        await loadScreen(tester);
        await tester.pumpAndSettle();
        expect(find.byType(ActivitiesScreen), findsOneWidget);
      });
    });

    testWidgets('should list activity', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        // Executa o comando loadActivities antes de carregar o widget
        await viewModel.loadActivities.execute();
        await loadScreen(tester);
        await tester.pumpAndSettle();
        expect(find.byType(ActivityEntry), findsOneWidget);
        expect(find.text('NAME'), findsOneWidget);
      });
    });

    testWidgets('should select activity and confirm', (
      WidgetTester tester,
    ) async {
      await mockNetworkImages(() async {
        // Executa o comando loadActivities antes de carregar o widget
        await viewModel.loadActivities.execute();
        await loadScreen(tester);
        await tester.pumpAndSettle();
        
        // Select one activity
        await tester.tap(find.byKey(const ValueKey('REF-checkbox')));
        expect(viewModel.selectedActivities, contains('REF'));

        // Text 1 selected should appear
        await tester.pumpAndSettle();
        expect(find.text('1 selected'), findsOneWidget);

        // Submit selection
        await tester.tap(find.byKey(const ValueKey('confirm-button')));

        // Should navigate to results screen
        verify(() => goRouter.go('/booking')).called(1);
      });
    });
  });
}
