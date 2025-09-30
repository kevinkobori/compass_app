import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('Navigation listener should detect route changes', (
    tester,
  ) async {
    var refreshCallCount = 0;
    const currentRoute = '/';

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => HookBuilder(
            builder: (context) {
              useEffect(
                () {
                  void onRouteChanged() {
                    final route = GoRouter.of(
                      context,
                    ).routerDelegate.currentConfiguration.uri.toString();
                    if (route == '/') {
                      refreshCallCount++;
                      print(
                        'Home detected - Refresh called: $refreshCallCount',
                      );
                    }
                  }

                  final router = GoRouter.of(context);
                  router.routerDelegate.addListener(onRouteChanged);

                  // Initial load
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    refreshCallCount++;
                    print('Initial load - Refresh called: $refreshCallCount');
                  });

                  return () =>
                      router.routerDelegate.removeListener(onRouteChanged);
                },
                [], // Empty dependencies
              );

              return Scaffold(
                body: Column(
                  children: [
                    const Text('Current Route: $currentRoute'),
                    Text('Refresh Count: $refreshCallCount'),
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

    print('=== TESTE: Build inicial da home ===');
    expect(refreshCallCount, 1, reason: 'Initial load deve chamar refresh');

    print('=== TESTE: Navegação para /search ===');
    await tester.tap(find.text('Go to Search'));
    await tester.pumpAndSettle();

    print('=== TESTE: Navegação de volta para home via context.go ===');
    await tester.tap(find.text('Back to Home'));
    await tester.pumpAndSettle();

    expect(
      refreshCallCount,
      greaterThan(1),
      reason: 'Navegação de volta deve chamar refresh',
    );
    print('Final refresh count: $refreshCallCount');
  });
}
