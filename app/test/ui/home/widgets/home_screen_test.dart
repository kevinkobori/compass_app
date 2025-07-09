// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:compass_app/config/dependencies.dart';
import 'package:compass_app/routing/routes.dart';
import 'package:compass_app/ui/home/view_models/home_viewmodel.dart';
import 'package:compass_app/ui/home/widgets/home_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:result_dart/result_dart.dart';

import '../../../../testing/app.dart';
import '../../../../testing/fakes/repositories/fake_auth_repository.dart';
import '../../../../testing/fakes/repositories/fake_booking_repository.dart';
import '../../../../testing/fakes/repositories/fake_itinerary_config_repository.dart';
import '../../../../testing/fakes/repositories/fake_user_repository.dart';
import '../../../../testing/mocks.dart';
import '../../../../testing/models/booking.dart';

void main() {
  group('HomeScreen tests', () {
    late HomeViewModel viewModel;
    late MockGoRouter goRouter;
    late FakeBookingRepository bookingRepository;
    late ProviderContainer container;

    setUp(() {
      bookingRepository = FakeBookingRepository()..createBooking(kBooking);
      container = ProviderContainer(overrides: [
        bookingRepositoryProvider.overrideWithValue(bookingRepository),
        userRepositoryProvider.overrideWithValue(FakeUserRepository()),
        authRepositoryProvider.overrideWith((ref) => FakeAuthRepository()),
        itineraryConfigRepositoryProvider.overrideWithValue(
          FakeItineraryConfigRepository(),
        ),
      ]);
      viewModel = container.read(homeViewModelProvider.notifier);
      goRouter = MockGoRouter();
      when(() => goRouter.push(any())).thenAnswer((_) => Future.value());
      when(() => goRouter.go(any())).thenAnswer((_) => Future.value());
    });

    tearDown(() {
      container.dispose();
    });

    Future<void> loadWidget(WidgetTester tester) async {
      await testApp(
        tester,
        UncontrolledProviderScope(
          container: container,
          child: const HomeScreen(),
        ),
        goRouter: goRouter,
      );
    }

    testWidgets('should load screen', (tester) async {
      await loadWidget(tester);
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('should show user name', (tester) async {
      await loadWidget(tester);
      await tester.pumpAndSettle();

      expect(find.text("NAME's Trips"), findsOneWidget);
    });

    testWidgets('should navigate to search', (tester) async {
      await loadWidget(tester);
      await tester.pumpAndSettle();

      // Tap on create a booking FAB
      await tester.tap(find.byKey(const ValueKey('booking-button')));
      await tester.pumpAndSettle();

      // Should navigate to results screen
      verify(() => goRouter.go(Routes.search)).called(1);
    });

    testWidgets('should open existing booking', (tester) async {
      await loadWidget(tester);
      await tester.pumpAndSettle();

      // Tap on booking (created from kBooking)
      await tester.tap(find.text('name1, Europe'));
      await tester.pumpAndSettle();

      // Should navigate to results screen
      verify(() => goRouter.push(Routes.bookingWithId(0))).called(1);
    });

    testWidgets('should delete booking', (tester) async {
      await loadWidget(tester);
      await tester.pumpAndSettle();

      // Swipe on booking (created from kBooking)
      await tester.drag(find.text('name1, Europe'), const Offset(-1000, 0));
      await tester.pumpAndSettle();

      // Existing booking should be gone
      expect(find.text('name1, Europe'), findsNothing);

      // Booking should be deleted from repository
      expect(bookingRepository.bookings, isEmpty);
    });

    testWidgets('fail to delete booking', (tester) async {
      final repo = _BadFakeBookingRepository();
      await repo.createBooking(kBooking);

      // Recreate container with failing repository
      container.dispose();
      container = ProviderContainer(overrides: [
        bookingRepositoryProvider.overrideWithValue(repo),
        userRepositoryProvider.overrideWithValue(FakeUserRepository()),
        authRepositoryProvider.overrideWith((ref) => FakeAuthRepository()),
        itineraryConfigRepositoryProvider.overrideWithValue(
          FakeItineraryConfigRepository(),
        ),
      ]);
      viewModel = container.read(homeViewModelProvider.notifier);

      await loadWidget(tester);
      await tester.pumpAndSettle();

      // Swipe on booking (created from kBooking)
      await tester.drag(find.text('name1, Europe'), const Offset(-1000, 0));
      await tester.pumpAndSettle();

      // Existing booking should be there
      expect(find.text('name1, Europe'), findsOneWidget);
    });
  });
}

class _BadFakeBookingRepository extends FakeBookingRepository {
  @override
  Future<Result<Unit>> delete(int id) async {
    return Failure(Exception('Failed to delete booking'));
  }
}
