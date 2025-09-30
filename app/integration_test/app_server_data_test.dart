import 'dart:io';

import 'package:compass_app/ui/activities/widgets/activities_screen.dart';
import 'package:compass_app/ui/auth/login/widgets/login_screen.dart';
import 'package:compass_app/ui/auth/logout/widgets/logout_button.dart';
import 'package:compass_app/ui/booking/widgets/booking_screen.dart';
import 'package:compass_app/ui/core/ui/custom_checkbox.dart';
import 'package:compass_app/ui/core/ui/home_button.dart';
import 'package:compass_app/ui/home/widgets/home_screen.dart';
import 'package:compass_app/ui/results/widgets/result_card.dart';
import 'package:compass_app/ui/results/widgets/results_screen.dart';
import 'package:compass_app/ui/search_form/widgets/search_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';

/// Parametrize para rodar o mesmo teste em ambos os idiomas
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test with remote data', () {
    const port = '8080';
    late Process p;

    setUpAll(() async {
      final sharedPreferences = await SharedPreferences.getInstance();
      await sharedPreferences.clear();

      p = await Process.start(
        'dart',
        ['run', 'bin/compass_server.dart'],
        environment: {'PORT': port},
        workingDirectory: '../server',
      );
      await p.stdout.first;
    });

    tearDownAll(() => p.kill());

    for (final locale in locales) {
      final strings = stringProviders[locale]!;

      testWidgets('should load app ($locale)', (tester) async {
        await pumpMainAppWithLocale(tester, locale);
        expect(find.byType(LoginScreen), findsOneWidget);
      });

      testWidgets('Open a booking ($locale)', (tester) async {
        await pumpMainAppWithLocale(tester, locale);

        expect(find.byType(LoginScreen), findsOneWidget);

        // Login
        expect(find.text(strings.login), findsOneWidget);
        await tester.tap(find.text(strings.login));
        await tester.pumpAndSettle();

        // Home screen
        expect(find.byType(HomeScreen), findsOneWidget);

        // Nome do usuário (parametrizado)
        expect(find.text(strings.nameTrips('Sofie')), findsOneWidget);

        // Tap on booking (Alaska is created by default)
        expect(find.text('Alaska, North America'), findsOneWidget);
        await tester.tap(find.text('Alaska, North America'));
        await tester.pumpAndSettle();

        // Booking screen
        expect(find.byType(BookingScreen), findsOneWidget);
        expect(find.text('Alaska'), findsOneWidget);

        // Navigate back to home
        await tester.tap(find.byType(HomeButton).first);
        await tester.pumpAndSettle();

        expect(find.byType(HomeScreen), findsOneWidget);

        // Perform logout
        await tester.tap(find.byType(LogoutButton).first);
        await tester.pumpAndSettle();
        expect(find.byType(LoginScreen), findsOneWidget);
      });

      testWidgets('Create booking ($locale)', (tester) async {
        await pumpMainAppWithLocale(tester, locale);

        expect(find.byType(LoginScreen), findsOneWidget);

        // Login
        expect(find.text(strings.login), findsOneWidget);
        await tester.tap(find.text(strings.login));
        await tester.pumpAndSettle();

        // Home screen
        expect(find.byType(HomeScreen), findsOneWidget);

        // Select create new booking
        await tester.tap(find.byKey(const ValueKey('booking-button')));
        await tester.pumpAndSettle();

        // Search destinations screen
        expect(find.byType(SearchFormScreen), findsOneWidget);

        // Select Europe because it is always the first result
        expect(find.text('Europe'), findsOneWidget);
        await tester.tap(find.text('Europe'), warnIfMissed: false);

        // Select dates
        expect(find.text(strings.addDates), findsOneWidget);
        await tester.tap(find.text(strings.addDates));
        await tester.pumpAndSettle();

        final tomorrow = DateTime.now().add(const Duration(days: 1)).day;
        final nextDay = DateTime.now().add(const Duration(days: 2)).day;
        await tester.tap(find.text(tomorrow.toString()).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text(nextDay.toString()).first);
        await tester.pumpAndSettle();

        expect(find.text(strings.save), findsOneWidget);
        await tester.tap(find.text(strings.save));
        await tester.pumpAndSettle();

        // Select guests
        await tester.tap(
          find.byKey(const ValueKey('add_guests')),
          warnIfMissed: false,
        );
        await tester.pumpAndSettle();

        // Perform search and navigate to next screen
        await tester.tap(find.byKey(const ValueKey('submit_button')));
        await tester.pumpAndSettle();

        // Results Screen
        expect(find.byType(ResultsScreen), findsOneWidget);

        // Amalfi Coast should be the first result for Europe
        await tester.tap(find.byType(ResultCard).first);
        await tester.pumpAndSettle();

        // Activities Screen
        expect(find.byType(ActivitiesScreen), findsOneWidget);

        // Select one activity
        await tester.tap(find.byType(CustomCheckbox).first);
        await tester.pumpAndSettle();
        expect(find.text(strings.selected(1)), findsOneWidget);

        // Submit selection
        await tester.tap(find.byKey(const ValueKey('confirm-button')));
        await tester.pumpAndSettle();

        // Should be at booking screen
        expect(find.byType(BookingScreen), findsOneWidget);
        expect(find.text('Amalfi Coast'), findsOneWidget);

        // Navigate back to home
        await tester.tap(find.byType(HomeButton).first);
        await tester.pumpAndSettle();

        expect(find.byType(HomeScreen), findsOneWidget);

        // New Booking should appear
        expect(find.text('Amalfi Coast, Europe'), findsOneWidget);

        // Perform logout
        await tester.tap(find.byType(LogoutButton).first);
        await tester.pumpAndSettle();
        expect(find.byType(LoginScreen), findsOneWidget);
      });
    }
  });
}
