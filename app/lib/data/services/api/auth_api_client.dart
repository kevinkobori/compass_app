// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../utils/result.dart';
import 'model/login_request/login_request.dart';
import 'model/login_response/login_response.dart';

class AuthApiClient {
  AuthApiClient({String? host, int? port, http.Client Function()? clientFactory})
      : _host = host ?? 'localhost',
        _port = port ?? 8080,
        _clientFactory = clientFactory ?? http.Client.new;

  final String _host;
  final int _port;
  final http.Client Function() _clientFactory;

  Future<Result<LoginResponse>> login(LoginRequest loginRequest) async {
    final client = _clientFactory();
    try {
      final uri = Uri.http('$_host:$_port', '/login');
      final response = await client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(loginRequest),
      );
      if (response.statusCode == 200) {
        return Result.ok(
          LoginResponse.fromJson(jsonDecode(response.body)),
        );
      } else {
        return const Result.error(Exception('Login error'));
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }
}
