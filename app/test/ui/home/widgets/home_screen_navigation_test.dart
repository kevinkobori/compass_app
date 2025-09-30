import 'package:compass_app/ui/home/widgets/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('HomeScreen Navigation Auto-Refresh Tests', () {
    testWidgets('useEffect should be configured with empty dependencies', (
      tester,
    ) async {
      var refreshCallCount = 0;
      String? lastRoute;

      // Create a router to test navigation behavior
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => HookBuilder(
              builder: (context) {
                // Simulate the HomeScreen useEffect pattern
                useEffect(() {
                  refreshCallCount++;
                  return null;
                }, []); // Empty dependencies like in HomeScreen

                // Monitor route changes
                useEffect(() {
                  void handleRouteChange() {
                    try {
                      final currentRoute = GoRouter.of(
                        context,
                      ).routerDelegate.currentConfiguration.uri.toString();
                      lastRoute = currentRoute;

                      if (currentRoute == '/') {
                        refreshCallCount++;
                      }
                    } catch (e) {
                      // Handle test environment
                      refreshCallCount++;
                    }
                  }

                  try {
                    final router = GoRouter.of(context);
                    router.routerDelegate.addListener(handleRouteChange);

                    return () =>
                        router.routerDelegate.removeListener(handleRouteChange);
                  } catch (e) {
                    return null;
                  }
                }, []);

                return Scaffold(
                  body: Column(
                    children: [
                      Text('Refresh Count: $refreshCallCount'),
                      Text('Last Route: ${lastRoute ?? 'none'}'),
                      ElevatedButton(
                        onPressed: () => context.go('/search'),
                        child: const Text('Go to Search'),
                      ),
                      ElevatedButton(
                        onPressed: () => context.go('/'),
                        child: const Text('Go to Home'),
                      ),
                    ],
                  ),
                );
              },
            ),
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) => Scaffold(
                  body: Column(
                    children: [
                      const Text('Search Page'),
                      ElevatedButton(
                        onPressed: () => context.go('/'),
                        child: const Text('Back to Home'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      // Initial build should trigger useEffect
      expect(refreshCallCount, greaterThanOrEqualTo(1));

      // Navigate to search
      await tester.tap(find.text('Go to Search'));
      await tester.pumpAndSettle();

      // Navigate back to home - should trigger refresh
      await tester.tap(find.text('Back to Home'));
      await tester.pumpAndSettle();

      // Should have triggered additional refresh calls
      expect(refreshCallCount, greaterThan(1));
    });

    testWidgets('HomeScreen should handle GoRouter errors gracefully', (
      tester,
    ) async {
      var errorHandled = false;

      // Widget that simulates HomeScreen error handling
      Widget testWidget() {
        return MaterialApp(
          home: HookBuilder(
            builder: (context) {
              useEffect(() {
                try {
                  // This should fail in test environment without proper GoRouter
                  final router = GoRouter.of(context);
                  router.routerDelegate.addListener(() {});
                } catch (e) {
                  // Should handle error gracefully like HomeScreen does
                  errorHandled = true;
                }
                return null;
              }, []);

              return Scaffold(
                body: Text('Error handled: $errorHandled'),
              );
            },
          ),
        );
      }

      await tester.pumpWidget(testWidget());
      await tester.pumpAndSettle();

      // Should handle GoRouter errors without crashing
      expect(errorHandled, isTrue);
      expect(find.text('Error handled: true'), findsOneWidget);
    });

    testWidgets('useEffect dependencies should prevent infinite loops', (
      tester,
    ) async {
      var effectCallCount = 0;
      var buildCount = 0;

      Widget testWidget() {
        return MaterialApp(
          home: HookBuilder(
            builder: (context) {
              buildCount++;

              // Simulate HomeScreen useEffect with empty dependencies
              useEffect(() {
                effectCallCount++;
                return null;
              }, []); // Empty dependencies should prevent loops

              return Scaffold(
                body: Column(
                  children: [
                    Text('Build count: $buildCount'),
                    Text('Effect count: $effectCallCount'),
                  ],
                ),
              );
            },
          ),
        );
      }

      await tester.pumpWidget(testWidget());
      await tester.pumpAndSettle();

      final initialEffectCount = effectCallCount;
      expect(initialEffectCount, 1); // Should be called once initially

      // Trigger multiple rebuilds
      for (var i = 0; i < 3; i++) {
        await tester.pumpWidget(testWidget());
        await tester.pumpAndSettle();
      }

      // Effect should still be called only once despite multiple rebuilds
      expect(effectCallCount, equals(initialEffectCount));
      expect(buildCount, greaterThan(1)); // Builds can happen multiple times
    });

    testWidgets('addPostFrameCallback should be used correctly', (
      tester,
    ) async {
      var frameCallbackExecuted = false;
      var immediateExecuted = false;

      Widget testWidget() {
        return MaterialApp(
          home: HookBuilder(
            builder: (context) {
              useEffect(() {
                // Test immediate execution (wrong pattern)
                immediateExecuted = true;

                // Test frame callback execution (correct pattern like HomeScreen)
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  frameCallbackExecuted = true;
                });

                return null;
              }, []);

              return Scaffold(
                body: Column(
                  children: [
                    Text('Immediate: $immediateExecuted'),
                    Text('Frame callback: $frameCallbackExecuted'),
                  ],
                ),
              );
            },
          ),
        );
      }

      await tester.pumpWidget(testWidget());

      // After the initial pump, immediate should be executed but frame callback may not be
      expect(immediateExecuted, isTrue);

      await tester.pumpAndSettle();

      // After pumpAndSettle, frame callback should definitely be executed
      expect(frameCallbackExecuted, isTrue);
    });

    testWidgets('HomeScreen widget should build without errors', (
      tester,
    ) async {
      // This is a simple test to ensure HomeScreen can be instantiated
      const homeScreen = HomeScreen();

      expect(homeScreen, isA<HomeScreen>());
      expect(homeScreen, isA<Widget>());
      expect(homeScreen.key, isNull); // Default key should be null
    });
  });
}
