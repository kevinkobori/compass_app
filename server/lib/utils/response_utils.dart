import 'dart:convert';

import 'package:shelf/shelf.dart';

/// Helper to create JSON [Response] objects with a consistent header.
Response jsonResponse(Object body, {int statusCode = 200}) {
  return Response(
    statusCode,
    body: json.encode(body),
    headers: const {'Content-Type': 'application/json'},
  );
}

