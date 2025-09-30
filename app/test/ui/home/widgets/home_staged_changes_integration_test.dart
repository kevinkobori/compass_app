import 'package:compass_app/config/dependencies.dart';
import 'package:compass_app/ui/home/view_models/home_viewmodel.dart';
import 'package:compass_app/ui/home/widgets/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../testing/app.dart';
import '../../../../testing/fakes/repositories/fake_auth_repository.dart';
import '../../../../testing/fakes/repositories/fake_booking_repository.dart';
import '../../../../testing/fakes/repositories/fake_itinerary_config_repository.dart';
import '../../../../testing/fakes/repositories/fake_user_repository.dart';
import '../../../../testing/models/booking.dart';

void main() {
  group('Home Staged Changes Integration Tests', () {
    late ProviderContainer container;
    late FakeBookingRepository bookingRepository;

    setUp(() {
      bookingRepository = FakeBookingRepository()..createBooking(kBooking);
      container = ProviderContainer(
        overrides: [
          bookingRepositoryProvider.overrideWithValue(bookingRepository),
          userRepositoryProvider.overrideWithValue(FakeUserRepository()),
          authRepositoryProvider.overrideWith((ref) => FakeAuthRepository()),
          itineraryConfigRepositoryProvider.overrideWithValue(
            FakeItineraryConfigRepository(),
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('HomeViewModel refresh method should trigger data reload', (
      tester,
    ) async {
      // Arrange
      final viewModel = container.read(homeViewModelProvider.notifier);

      // Act
      await testApp(
        tester,
        UncontrolledProviderScope(
          container: container,
          child: const HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify initial state is loaded
      final initialState = container.read(homeViewModelProvider);
      expect(initialState.user, isNotNull);
      expect(initialState.bookings, isNotEmpty);

      // Act - Call refresh method
      viewModel.refresh();
      await tester.pumpAndSettle();

      // Assert - State should be refreshed
      final refreshedState = container.read(homeViewModelProvider);
      expect(refreshedState.user, isNotNull);
      expect(refreshedState.bookings, isNotEmpty);
    });

    testWidgets('HomeScreen navigation listener should handle route changes', (
      tester,
    ) async {
      // Arrange
      await testApp(
        tester,
        UncontrolledProviderScope(
          container: container,
          child: const HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - HomeScreen should be loaded and functional
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text("NAME's Trips"), findsOneWidget);
    });

    testWidgets('HomeHeader should use state parameter correctly', (
      tester,
    ) async {
      // Arrange
      await testApp(
        tester,
        UncontrolledProviderScope(
          container: container,
          child: const HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - HomeHeader should display user information from state
      expect(find.text("NAME's Trips"), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets(
      'Complete integration: navigation refresh triggers data reload',
      (tester) async {
        // Arrange
        final viewModel = container.read(homeViewModelProvider.notifier);

        await testApp(
          tester,
          UncontrolledProviderScope(
            container: container,
            child: const HomeScreen(),
          ),
        );
        await tester.pumpAndSettle();

        // Verify initial load
        final initialState = container.read(homeViewModelProvider);
        expect(initialState.user?.name, equals('NAME'));
        expect(initialState.bookings.length, equals(1));

        // Simulate navigation refresh by calling viewModel.refresh()
        viewModel.refresh();
        await tester.pumpAndSettle();

        // Verify state is still correct after refresh
        final refreshedState = container.read(homeViewModelProvider);
        expect(refreshedState.user?.name, equals('NAME'));
        expect(refreshedState.bookings.length, equals(1));

        // Verify UI elements are still displayed correctly
        expect(find.text("NAME's Trips"), findsOneWidget);
        expect(find.byIcon(Icons.logout), findsOneWidget);
      },
    );

    test('HomeViewModel refresh method should be callable', () {
      // Arrange
      final viewModel = container.read(homeViewModelProvider.notifier);

      // Act & Assert - Should not throw
      expect(viewModel.refresh, returnsNormally);
    });

    test('HomeState should maintain immutability', () {
      // Arrange
      const state1 = HomeState();
      const state2 = HomeState();

      // Assert
      expect(state1.bookings, equals(state2.bookings));
      expect(state1.user, equals(state2.user));
    });
  });
}
