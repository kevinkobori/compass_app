import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('useEffect with empty dependencies should run only once', (
    tester,
  ) async {
    var effectCallCount = 0;

    Widget buildTestWidget() {
      return MaterialApp(
        home: HookBuilder(
          builder: (context) {
            useEffect(() {
              effectCallCount++;
              print('Effect called: $effectCallCount');
              return null;
            }, []); // Empty dependencies - should run only once

            return Scaffold(
              body: Text('Call count: $effectCallCount'),
            );
          },
        ),
      );
    }

    print('=== TESTE: Build inicial ===');
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(
      effectCallCount,
      1,
      reason: 'Effect deve ser chamado apenas uma vez no build inicial',
    );
    print('Build inicial - Effect count: $effectCallCount');

    print('=== TESTE: Rebuild 1 ===');
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(
      effectCallCount,
      1,
      reason: 'Effect NÃO deve ser chamado novamente no rebuild',
    );
    print('Rebuild 1 - Effect count: $effectCallCount (deve permanecer 1)');

    print('=== TESTE: Rebuild 2 ===');
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(
      effectCallCount,
      1,
      reason: 'Effect NÃO deve ser chamado no segundo rebuild',
    );
    print('Rebuild 2 - Effect count: $effectCallCount (deve permanecer 1)');

    print(
      '=== TESTE CONCLUÍDO: useEffect com dependências vazias funciona (sem loop infinito) ===',
    );
  });

  testWidgets('Multiple rebuilds should not trigger infinite loops', (
    tester,
  ) async {
    var effectCallCount = 0;
    var buildCount = 0;

    Widget buildTestWidget() {
      return MaterialApp(
        home: HookBuilder(
          builder: (context) {
            buildCount++;

            useEffect(() {
              effectCallCount++;
              print('Effect called: $effectCallCount on build: $buildCount');
              return null;
            }, []); // Empty dependencies

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

    // Initial build
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(effectCallCount, 1);
    expect(buildCount, 1);

    // Trigger multiple rebuilds
    for (var i = 0; i < 5; i++) {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();
    }

    // Effect should still be called only once, but build can be called multiple times
    expect(
      effectCallCount,
      1,
      reason: 'Effect deve ser executado apenas uma vez',
    );
    expect(
      buildCount,
      greaterThan(1),
      reason: 'Build pode ser executado múltiplas vezes',
    );

    print('Final - Effect count: $effectCallCount, Build count: $buildCount');
  });
}
