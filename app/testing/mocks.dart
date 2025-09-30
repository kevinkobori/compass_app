// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class MockGoRouter extends Mock implements GoRouter {
  @override
  GoRouterDelegate get routerDelegate {
    final delegate = MockGoRouterDelegate();
    when(() => delegate.currentConfiguration).thenReturn(
      RouteMatchList(
        matches: const <RouteMatch>[],
        uri: Uri.parse('/'),
        pathParameters: const <String, String>{},
      ),
    );
    return delegate;
  }
}

class MockGoRouterDelegate extends Mock implements GoRouterDelegate {}

class MockHttpClient extends Mock implements http.Client {}

extension HttpMethodMocks on MockHttpClient {
  void mockGet(String path, Object object) {
    when(
      () =>
          get(Uri.http('localhost:8080', path), headers: any(named: 'headers')),
    ).thenAnswer((_) async => http.Response(jsonEncode(object), 200));
  }

  void mockPost(String path, Object object, [int statusCode = 201]) {
    when(
      () => post(
        Uri.http('localhost:8080', path),
        headers: any(named: 'headers'),
        body: any(named: 'body'),
      ),
    ).thenAnswer((_) async => http.Response(jsonEncode(object), statusCode));
  }

  void mockDelete(String path) {
    when(
      () => delete(
        Uri.http('localhost:8080', path),
        headers: any(named: 'headers'),
      ),
    ).thenAnswer((_) async => http.Response('', 204));
  }
}
