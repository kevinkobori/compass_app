// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:compass_app/config/dependencies.dart';
import 'package:compass_app/ui/search_form/view_models/search_form_viewmodel.dart';
import 'package:compass_app/ui/search_form/widgets/search_form_guests.dart';
import 'package:compass_app/ui/search_form/widgets/search_form_screen.dart';
import 'package:compass_app/ui/search_form/widgets/search_form_submit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../testing/app.dart';
import '../../../../testing/fakes/repositories/fake_auth_repository.dart';
import '../../../../testing/fakes/repositories/fake_continent_repository.dart';
import '../../../../testing/fakes/repositories/fake_itinerary_config_repository.dart';
import '../../../../testing/mocks.dart';

void main() {
  group('SearchFormScreen widget tests', () {
    late MockGoRouter goRouter;
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(overrides: [
        continentRepositoryProvider.overrideWithValue(FakeContinentRepository()),
        itineraryConfigRepositoryProvider.overrideWithValue(
          FakeItineraryConfigRepository(),
        ),
        authRepositoryProvider.overrideWith((ref) => FakeAuthRepository()),
      ]);
      goRouter = MockGoRouter();
    });

    tearDown(() {
      container.dispose();
    });

    Future<void> loadWidget(WidgetTester tester) async {
      await testApp(
        tester,
        UncontrolledProviderScope(
          container: container,
          child: const SearchFormScreen(),
        ),
        goRouter: goRouter,
      );
    }

    testWidgets('Should fill form and perform search', (
      WidgetTester tester,
    ) async {
      await loadWidget(tester);
      
      // Executa o comando load através do provider
      final vm = container.read(searchFormViewModelProvider.notifier);
      await vm.load.execute();
      await tester.pump(); // Pump para reconstruir com os novos dados
      
      expect(find.byType(SearchFormScreen), findsOneWidget);

      // Verificar se o texto está disponível
      expect(find.text('CONTINENT'), findsOneWidget);

      // Scroll para o elemento antes de tentar clicar
      await tester.ensureVisible(find.text('CONTINENT'));
      await tester.pump();

      // Select continent
      await tester.tap(find.text('CONTINENT'), warnIfMissed: false);
      // Aguarda animações terminarem
      await tester.pump(kThemeChangeDuration);
      await tester.pump();

      // Select date
      vm.dateRange = DateTimeRange(
        start: DateTime(2024, 6, 12),
        end: DateTime(2024, 7, 23),
      );
      await tester.pump();

      // Select guests
      await tester.tap(find.byKey(const ValueKey(addGuestsKey)));
      await tester.pump();

      // Perform search
      await tester.tap(find.byKey(const ValueKey(searchFormSubmitButtonKey)));
      await tester.pump();

      // Should navigate to results screen
      verify(() => goRouter.go('/results')).called(1);
    });
  });
}
