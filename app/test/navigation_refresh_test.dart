import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('useEffect with viewModel dependency should work correctly', (
    tester,
  ) async {
    var effectCallCount = 0;
    String? viewModelInstance;

    Widget buildTestWidget({String? instanceId}) {
      return MaterialApp(
        home: HookBuilder(
          builder: (context) {
            // Simulate viewModel instance (changes when screen is recreated)
            final currentViewModel = instanceId ?? 'instance-1';

            useEffect(() {
              effectCallCount++;
              print(
                'Effect called: $effectCallCount for viewModel: $currentViewModel',
              );
              return null;
            }, [currentViewModel]); // Depend on viewModel instance

            viewModelInstance = currentViewModel;

            return Scaffold(
              body: Column(
                children: [
                  Text('ViewModel: $currentViewModel'),
                  Text('Effect count: $effectCallCount'),
                ],
              ),
            );
          },
        ),
      );
    }

    print('=== TESTE: Build inicial com instance-1 ===');
    await tester.pumpWidget(buildTestWidget(instanceId: 'instance-1'));
    await tester.pumpAndSettle();

    expect(effectCallCount, 1);
    expect(viewModelInstance, 'instance-1');
    print('Instance-1 - Effect count: $effectCallCount');

    print('=== TESTE: Rebuild com mesma instance-1 ===');
    await tester.pumpWidget(buildTestWidget(instanceId: 'instance-1'));
    await tester.pumpAndSettle();

    expect(
      effectCallCount,
      1,
      reason: 'Effect NÃO deve executar para mesma instância',
    );
    print(
      'Same instance-1 - Effect count: $effectCallCount (deve permanecer 1)',
    );

    print('=== TESTE: Navegação simula nova instância (context.go) ===');
    await tester.pumpWidget(buildTestWidget(instanceId: 'instance-2'));
    await tester.pumpAndSettle();

    expect(
      effectCallCount,
      2,
      reason: 'Effect deve executar para nova instância',
    );
    expect(viewModelInstance, 'instance-2');
    print('Instance-2 - Effect count: $effectCallCount');

    print('=== TESTE: Mais rebuilds com instance-2 ===');
    for (var i = 0; i < 3; i++) {
      await tester.pumpWidget(buildTestWidget(instanceId: 'instance-2'));
      await tester.pumpAndSettle();
    }

    expect(
      effectCallCount,
      2,
      reason: 'Effect NÃO deve executar em rebuilds da mesma instância',
    );
    print(
      'Multiple rebuilds instance-2 - Effect count: $effectCallCount (deve permanecer 2)',
    );

    print(
      '=== TESTE CONCLUÍDO: useEffect com dependência do viewModel funciona ===',
    );
  });
}
