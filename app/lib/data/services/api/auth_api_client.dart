// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../utils/result.dart';
import 'model/login_request/login_request.dart';
import 'model/login_response/login_response.dart';

class AuthApiClient {
  AuthApiClient({
    String? host,
    int? port,
    http.Client Function()? clientFactory,
  }) : _host = host ?? 'localhost',
       _port = port ?? 8080,
       _clientFactory = clientFactory ?? http.Client.new;

  final String _host;
  final int _port;
  final http.Client Function() _clientFactory;

  Future<Result<T>> _send<T>(
    Future<http.Response> Function(http.Client) requestFn,
    T Function(String body) parse,
    int expectedStatus,
  ) async {
    final client = _clientFactory();
    try {
      final response = await requestFn(client);
      if (response.statusCode == expectedStatus) {
        return Result.ok(parse(response.body));
      } else {
        return Result.error(Exception('Login error'));
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<LoginResponse>> login(LoginRequest loginRequest) async {
    return _send(
      (client) => client.post(
        Uri.http('$_host:$_port', '/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(loginRequest),
      ),
      (body) => LoginResponse.fromJson(jsonDecode(body)),
      200,
    );
  }
}
