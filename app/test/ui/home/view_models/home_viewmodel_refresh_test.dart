import 'package:compass_app/config/dependencies.dart';
import 'package:compass_app/data/repositories/booking/booking_repository.dart';
import 'package:compass_app/data/repositories/user/user_repository.dart';
import 'package:compass_app/ui/home/view_models/home_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:result_dart/result_dart.dart';

import '../../../../testing/models/booking.dart';
import '../../../../testing/models/user.dart';

class MockBookingRepository extends Mock implements BookingRepository {}

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  group('HomeViewModel refresh() method tests', () {
    late MockBookingRepository mockBookingRepository;
    late MockUserRepository mockUserRepository;
    late ProviderContainer container;

    setUp(() {
      mockBookingRepository = MockBookingRepository();
      mockUserRepository = MockUserRepository();

      container = ProviderContainer(
        overrides: [
          bookingRepositoryProvider.overrideWithValue(mockBookingRepository),
          userRepositoryProvider.overrideWithValue(mockUserRepository),
        ],
      );

      // Setup successful responses by default
      when(
        () => mockBookingRepository.getBookingsList(),
      ).thenAnswer((_) async => const Success([]));
      when(
        () => mockUserRepository.getUser(),
      ).thenAnswer((_) async => const Success(user));
    });

    tearDown(() {
      container.dispose();
    });

    test('refresh() method should exist and be callable', () {
      // Arrange
      final viewModel = container.read(homeViewModelProvider.notifier);

      // Act & Assert - Should not throw
      expect(viewModel.refresh, returnsNormally);
    });

    test('refresh() should trigger load command execution', () async {
      // Arrange
      final viewModel = container.read(homeViewModelProvider.notifier);

      // Wait for initial load to settle
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Reset mocks to clear initial load calls
      reset(mockBookingRepository);
      reset(mockUserRepository);

      when(
        () => mockBookingRepository.getBookingsList(),
      ).thenAnswer((_) async => const Success([]));
      when(
        () => mockUserRepository.getUser(),
      ).thenAnswer((_) async => const Success(user));

      // Act
      viewModel.refresh();

      // Wait for async operations
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Assert
      verify(() => mockBookingRepository.getBookingsList()).called(1);
      verify(() => mockUserRepository.getUser()).called(1);
    });

    test('refresh() should update state with new data', () async {
      // Arrange
      final newBookings = [kBookingSummary];
      final newUser = user.copyWith(name: 'Updated User');

      when(
        () => mockBookingRepository.getBookingsList(),
      ).thenAnswer((_) async => Success(newBookings));
      when(
        () => mockUserRepository.getUser(),
      ).thenAnswer((_) async => Success(newUser));

      final viewModel = container.read(homeViewModelProvider.notifier);

      // Wait for initial load
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Act
      viewModel.refresh();
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Assert
      final state = container.read(homeViewModelProvider);
      expect(state.bookings, equals(newBookings));
      expect(state.user, equals(newUser));
    });

    test('refresh() should handle repository errors gracefully', () async {
      // Arrange
      when(
        () => mockBookingRepository.getBookingsList(),
      ).thenAnswer((_) async => Failure(Exception('Network error')));
      when(
        () => mockUserRepository.getUser(),
      ).thenAnswer((_) async => const Success(user));

      final viewModel = container.read(homeViewModelProvider.notifier);

      // Act
      viewModel.refresh();
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Assert - Should not crash and command should be in failure state
      expect(viewModel.load.value.isFailure, isTrue);
    });

    test('refresh() should work multiple times consecutively', () async {
      // Arrange
      final viewModel = container.read(homeViewModelProvider.notifier);

      // Wait for initial load
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Reset mocks for counting
      reset(mockBookingRepository);
      reset(mockUserRepository);

      when(
        () => mockBookingRepository.getBookingsList(),
      ).thenAnswer((_) async => const Success([]));
      when(
        () => mockUserRepository.getUser(),
      ).thenAnswer((_) async => const Success(user));

      // Act - Multiple refreshes
      viewModel.refresh();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      viewModel.refresh();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      viewModel.refresh();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Assert - Should handle multiple calls without issues
      expect(viewModel.refresh, returnsNormally);
    });

    test('refresh() should maintain HomeViewModel interface', () {
      // Arrange
      final viewModel = container.read(homeViewModelProvider.notifier);

      // Assert - refresh method should be available as part of the public API
      expect(viewModel, isA<HomeViewModel>());
      expect(viewModel.refresh, isA<Function>());
    });

    test('HomeState should have correct properties after refresh', () async {
      // Arrange
      final testBookings = [kBookingSummary];
      const testUser = user;

      when(
        () => mockBookingRepository.getBookingsList(),
      ).thenAnswer((_) async => Success(testBookings));
      when(
        () => mockUserRepository.getUser(),
      ).thenAnswer((_) async => const Success(testUser));

      final viewModel = container.read(homeViewModelProvider.notifier);

      // Act
      viewModel.refresh();
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Assert
      final state = container.read(homeViewModelProvider);
      expect(state, isA<HomeState>());
      expect(state.bookings, isA<List<dynamic>>());
      expect(state.user, isA<Object?>());
      expect(state.bookings, equals(testBookings));
      expect(state.user, equals(testUser));
    });
  });
}
