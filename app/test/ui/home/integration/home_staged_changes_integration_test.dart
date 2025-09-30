import 'package:compass_app/config/dependencies.dart';
import 'package:compass_app/data/repositories/booking/booking_repository.dart';
import 'package:compass_app/data/repositories/user/user_repository.dart';
import 'package:compass_app/ui/home/view_models/home_viewmodel.dart';
import 'package:compass_app/ui/home/widgets/home_screen.dart';
import 'package:compass_app/ui/home/widgets/home_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:result_dart/result_dart.dart';

import '../../../../testing/app.dart';
import '../../../../testing/models/booking.dart';
import '../../../../testing/models/user.dart';

class MockBookingRepository extends Mock implements BookingRepository {}

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  group('Home Integration Tests - Staged Changes', () {
    late MockBookingRepository mockBookingRepository;
    late MockUserRepository mockUserRepository;

    setUp(() {
      mockBookingRepository = MockBookingRepository();
      mockUserRepository = MockUserRepository();

      // Setup default successful responses
      when(
        () => mockBookingRepository.getBookingsList(),
      ).thenAnswer((_) async => Success([kBookingSummary]));
      when(
        () => mockUserRepository.getUser(),
      ).thenAnswer((_) async => const Success(user));
    });

    testWidgets('Complete integration: refresh() -> state -> HomeHeader', (
      tester,
    ) async {
      // Arrange
      await testApp(
        tester,
        ProviderScope(
          overrides: [
            bookingRepositoryProvider.overrideWithValue(mockBookingRepository),
            userRepositoryProvider.overrideWithValue(mockUserRepository),
          ],
          child: Consumer(
            builder: (context, ref, child) {
              final viewModel = ref.read(homeViewModelProvider.notifier);
              final state = ref.watch(homeViewModelProvider);

              return Column(
                children: [
                  // Test the HomeHeader with state parameter
                  HomeHeader(state: state),

                  // Test refresh functionality
                  ElevatedButton(
                    onPressed: viewModel.refresh,
                    child: const Text('Refresh'),
                  ),

                  // Display state for testing
                  Text('Bookings: ${state.bookings.length}'),
                  if (state.user != null) Text('User: ${state.user!.name}'),
                ],
              );
            },
          ),
        ),
      );

      // Assert initial state
      expect(find.text("NAME's Trips"), findsOneWidget);
      expect(find.text('Bookings: 1'), findsOneWidget);
      expect(find.text('User: NAME'), findsOneWidget);

      // Act - Test refresh functionality
      reset(mockBookingRepository);
      reset(mockUserRepository);

      final newBookings = [
        kBookingSummary,
        kBookingSummary.copyWith(id: 999, name: 'New Trip'),
      ];

      when(
        () => mockBookingRepository.getBookingsList(),
      ).thenAnswer((_) async => Success(newBookings));
      when(
        () => mockUserRepository.getUser(),
      ).thenAnswer((_) async => const Success(user));

      await tester.tap(find.text('Refresh'));
      await tester.pumpAndSettle();

      // Assert after refresh
      expect(find.text('Bookings: 2'), findsOneWidget);
      verify(() => mockBookingRepository.getBookingsList()).called(1);
      verify(() => mockUserRepository.getUser()).called(1);
    });

    testWidgets('HomeScreen auto-refresh integration test', (
      tester,
    ) async {
      // Arrange - Track refresh calls
      var refreshCalls = 0;
      when(() => mockBookingRepository.getBookingsList()).thenAnswer((_) async {
        refreshCalls++;
        return const Success([]);
      });

      await testApp(
        tester,
        ProviderScope(
          overrides: [
            bookingRepositoryProvider.overrideWithValue(mockBookingRepository),
            userRepositoryProvider.overrideWithValue(mockUserRepository),
          ],
          child: const HomeScreen(),
        ),
      );

      // Assert - Initial load should have called repositories
      expect(refreshCalls, greaterThanOrEqualTo(1));

      // Verify repositories were called
      verify(
        () => mockBookingRepository.getBookingsList(),
      ).called(greaterThanOrEqualTo(1));
      verify(
        () => mockUserRepository.getUser(),
      ).called(greaterThanOrEqualTo(1));
    });

    testWidgets('HomeScreen should handle error states gracefully', (
      tester,
    ) async {
      // Arrange - Setup error response
      when(
        () => mockBookingRepository.getBookingsList(),
      ).thenAnswer((_) async => Failure(Exception('Network error')));
      when(
        () => mockUserRepository.getUser(),
      ).thenAnswer((_) async => const Success(user));

      await testApp(
        tester,
        ProviderScope(
          overrides: [
            bookingRepositoryProvider.overrideWithValue(mockBookingRepository),
            userRepositoryProvider.overrideWithValue(mockUserRepository),
          ],
          child: const HomeScreen(),
        ),
      );

      // Assert - Should display error state
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets(
      'State parameter flow: HomeViewModel -> HomeState -> HomeHeader',
      (
        tester,
      ) async {
        // Arrange
        const testUser = user;
        final testBookings = [kBookingSummary];

        when(
          () => mockBookingRepository.getBookingsList(),
        ).thenAnswer((_) async => Success(testBookings));
        when(
          () => mockUserRepository.getUser(),
        ).thenAnswer((_) async => const Success(testUser));

        await testApp(
          tester,
          ProviderScope(
            overrides: [
              bookingRepositoryProvider.overrideWithValue(
                mockBookingRepository,
              ),
              userRepositoryProvider.overrideWithValue(mockUserRepository),
            ],
            child: Consumer(
              builder: (context, ref, child) {
                final state = ref.watch(homeViewModelProvider);

                return Column(
                  children: [
                    // Test that HomeHeader correctly receives state
                    HomeHeader(state: state),

                    // Verify state contents
                    Text('State has user: ${state.user != null}'),
                    Text('State bookings count: ${state.bookings.length}'),
                  ],
                );
              },
            ),
          ),
        );

        // Assert - Verify complete data flow
        expect(find.text("NAME's Trips"), findsOneWidget);
        expect(find.text('State has user: true'), findsOneWidget);
        expect(find.text('State bookings count: 1'), findsOneWidget);
      },
    );

    testWidgets('Refresh method availability and integration', (
      tester,
    ) async {
      // This test verifies that the refresh method is properly exposed and integrated

      late HomeViewModel capturedViewModel;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bookingRepositoryProvider.overrideWithValue(mockBookingRepository),
            userRepositoryProvider.overrideWithValue(mockUserRepository),
          ],
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, child) {
                capturedViewModel = ref.read(homeViewModelProvider.notifier);

                return const Scaffold(
                  body: Text('Test Widget'),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert - Verify refresh method exists and is callable
      expect(capturedViewModel, isA<HomeViewModel>());
      expect(capturedViewModel.refresh, isA<Function>());
      expect(() => capturedViewModel.refresh(), returnsNormally);
    });

    test('HomeState immutability and copyWith functionality', () {
      // Arrange
      const originalState = HomeState();

      final newBookings = [kBookingSummary];
      const newUser = user;

      // Act
      final newState = originalState.copyWith(
        bookings: newBookings,
        user: newUser,
      );

      // Assert
      expect(newState.bookings, equals(newBookings));
      expect(newState.user, equals(newUser));
      expect(newState, isNot(equals(originalState)));

      // Original state should remain unchanged
      expect(originalState.bookings, isEmpty);
      expect(originalState.user, isNull);
    });
  });
}
