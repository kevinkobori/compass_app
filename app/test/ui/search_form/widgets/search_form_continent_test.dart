// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:compass_app/config/dependencies.dart';
import 'package:compass_app/ui/search_form/view_models/search_form_viewmodel.dart';
import 'package:compass_app/ui/search_form/widgets/search_form_continent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../testing/app.dart';
import '../../../../testing/fakes/repositories/fake_continent_repository.dart';
import '../../../../testing/fakes/repositories/fake_itinerary_config_repository.dart';

void main() {
  group('SearchFormContinent widget tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(overrides: [
        continentRepositoryProvider.overrideWithValue(FakeContinentRepository()),
        itineraryConfigRepositoryProvider.overrideWithValue(
          FakeItineraryConfigRepository(),
        ),
      ]);
    });

    tearDown(() {
      container.dispose();
    });

    Future<void> loadWidget(WidgetTester tester) async {
      await testApp(
        tester,
        UncontrolledProviderScope(
          container: container,
          child: Consumer(
            builder: (context, ref, child) {
              final vm = ref.watch(searchFormViewModelProvider.notifier);
              return SearchFormContinent(viewModel: vm);
            },
          ),
        ),
      );
    }

    testWidgets('Should load and select continent', (
      WidgetTester tester,
    ) async {
      await loadWidget(tester);
      
      // Executa o comando load através do provider
      final vm = container.read(searchFormViewModelProvider.notifier);
      await vm.load.execute();
      await tester.pump(); // Pump para reconstruir com os novos dados
      
      expect(find.byType(SearchFormContinent), findsOneWidget);

      // Verificar se o texto está disponível
      expect(find.text('CONTINENT'), findsOneWidget);

      // Scroll para o elemento antes de tentar clicar
      await tester.ensureVisible(find.text('CONTINENT'));
      await tester.pump();

      // Select continent
      await tester.tap(find.text('CONTINENT'), warnIfMissed: false);
      await tester.pump(kThemeChangeDuration);
      await tester.pump();

      // Verificar se continente foi selecionado
      expect(vm.selectedContinent, equals('CONTINENT'));
    });
  });
}
