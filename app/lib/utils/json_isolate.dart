import 'dart:convert';
import 'dart:isolate';

/// Parse a JSON map in an isolate using [fromJson].
Future<T> parseJsonMapInIsolate<T>(
  String source,
  T Function(Map<String, dynamic>) fromJson,
) {
  return Isolate.run(() {
    final map = jsonDecode(source) as Map<String, dynamic>;
    return fromJson(map);
  });
}

/// Parse a JSON list in an isolate using [fromJson].
Future<List<T>> parseJsonListInIsolate<T>(
  String source,
  T Function(Map<String, dynamic>) fromJson,
) {
  return Isolate.run(() {
    final list = jsonDecode(source) as List<dynamic>;
    return list.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  });
}

/// Decode a JSON list into a list of maps in an isolate.
Future<List<Map<String, dynamic>>> parseMapListInIsolate(String source) {
  return Isolate.run(() {
    return (jsonDecode(source) as List<dynamic>).cast<Map<String, dynamic>>();
  });
}
