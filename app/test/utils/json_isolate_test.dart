import 'package:compass_app/utils/json_isolate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JsonIsolate utilities', () {
    test('should parse map using isolate', () async {
      const data = '{"a":1}';
      final result = await parseJsonMapInIsolate<Map<String, dynamic>>(
        data,
        (e) => e,
      );
      expect(result, {'a': 1});
    });

    test('should parse list using isolate', () async {
      const data = '[{"a":1},{"a":2}]';
      final list = await parseJsonListInIsolate<Map<String, dynamic>>(
        data,
        (e) => e,
      );
      expect(list, [
        {'a': 1},
        {'a': 2},
      ]);
    });

    test('should parse map list using isolate', () async {
      const data = '[{"a":1},{"a":2}]';
      final list = await parseMapListInIsolate(data);
      expect(list, [
        {'a': 1},
        {'a': 2},
      ]);
    });
  });
}
