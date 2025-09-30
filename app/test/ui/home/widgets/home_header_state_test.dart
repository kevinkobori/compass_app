import 'package:compass_app/config/dependencies.dart';
import 'package:compass_app/domain/models/user/user.dart';
import 'package:compass_app/ui/home/view_models/home_viewmodel.dart';
import 'package:compass_app/ui/home/widgets/home_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../testing/app.dart';
import '../../../../testing/fakes/repositories/fake_auth_repository.dart';
import '../../../../testing/fakes/repositories/fake_itinerary_config_repository.dart';
import '../../../../testing/models/user.dart';

void main() {
  group('HomeHeader State Parameter Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
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

    testWidgets('HomeHeader should display user information from state', (
      tester,
    ) async {
      // Arrange
      const state = HomeState(
        user: user,
      );

      // Act
      await testApp(
        tester,
        UncontrolledProviderScope(
          container: container,
          child: const HomeHeader(state: state),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text("NAME's Trips"), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('HomeHeader should display correct user name from state', (
      tester,
    ) async {
      // Arrange
      const customUser = User(
        name: 'Custom User',
        picture: 'assets/user.jpg',
      );

      const state = HomeState(
        user: customUser,
      );

      // Act
      await testApp(
        tester,
        UncontrolledProviderScope(
          container: container,
          child: const HomeHeader(state: state),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text("Custom User's Trips"), findsOneWidget);
    });

    testWidgets('HomeHeader should display logout button', (tester) async {
      // Arrange
      const state = HomeState(
        user: user,
      );

      // Act
      await testApp(
        tester,
        UncontrolledProviderScope(
          container: container,
          child: const HomeHeader(state: state),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets('HomeHeader should have correct structure', (tester) async {
      // Arrange
      const state = HomeState(
        user: user,
      );

      // Act
      await testApp(
        tester,
        UncontrolledProviderScope(
          container: container,
          child: const HomeHeader(state: state),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Row), findsOneWidget);
      expect(find.byType(ClipOval), findsOneWidget);
    });

    testWidgets('HomeHeader should return empty widget when user is null', (
      tester,
    ) async {
      // Arrange
      const state = HomeState();

      // Act
      await testApp(
        tester,
        UncontrolledProviderScope(
          container: container,
          child: const HomeHeader(state: state),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.byType(Column), findsNothing);
    });
  });
}
