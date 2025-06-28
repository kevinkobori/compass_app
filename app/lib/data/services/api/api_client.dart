// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

import '../../../domain/models/activity/activity.dart';
import '../../../domain/models/continent/continent.dart';
import '../../../domain/models/destination/destination.dart';
import '../../../utils/json_isolate.dart';
import '../../../utils/result.dart';
import 'model/booking/booking_api_model.dart';
import 'model/user/user_api_model.dart';

/// Adds the `Authentication` header to a header configuration.
typedef AuthHeaderProvider = String? Function();

class ApiClient {
  ApiClient({String? host, int? port, http.Client Function()? clientFactory})
    : _host = host ?? 'localhost',
      _port = port ?? 8080,
      _clientFactory = clientFactory ?? http.Client.new;

  final String _host;
  final int _port;
  final http.Client Function() _clientFactory;

  AuthHeaderProvider? _authHeaderProvider;

  set authHeaderProvider(AuthHeaderProvider authHeaderProvider) {
    _authHeaderProvider = authHeaderProvider;
  }

  Map<String, String> _authHeader() {
    final header = _authHeaderProvider?.call();
    return header != null ? {'Authorization': header} : <String, String>{};
  }

  Future<Result<T>> _send<T>(
    Future<http.Response> Function(http.Client) requestFn,
    Future<T> Function(String body) parse,
    int expectedStatus,
  ) async {
    final client = _clientFactory();
    try {
      final response = await requestFn(client);
      if (response.statusCode == expectedStatus) {
        final data = await parse(utf8.decode(response.bodyBytes));
        return Result.ok(data);
      } else {
        return Result.error(Exception('Invalid response'));
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<void>> _sendVoid(
    Future<http.Response> Function(http.Client) requestFn,
    int expectedStatus,
  ) async {
    final client = _clientFactory();
    try {
      final response = await requestFn(client);
      if (response.statusCode == expectedStatus) {
        return const Result.ok(null);
      } else {
        return Result.error(Exception('Invalid response'));
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<List<Continent>>> getContinents() async {
    return _send(
      (client) => client.get(
        Uri.http('$_host:$_port', '/continent'),
        headers: _authHeader(),
      ),
      (body) async => kIsWeb
          ? (jsonDecode(body) as List)
              .map((e) => Continent.fromJson(e))
              .toList()
          : await parseJsonListInIsolate(body, Continent.fromJson),
      200,
    );
  }

  Future<Result<List<Destination>>> getDestinations() async {
    return _send(
      (client) => client.get(
        Uri.http('$_host:$_port', '/destination'),
        headers: _authHeader(),
      ),
      (body) async => kIsWeb
          ? (jsonDecode(body) as List)
              .map((e) => Destination.fromJson(e))
              .toList()
          : await parseJsonListInIsolate(body, Destination.fromJson),
      200,
    );
  }

  Future<Result<List<Activity>>> getActivityByDestination(String ref) async {
    return _send(
      (client) => client.get(
        Uri.http('$_host:$_port', '/destination/$ref/activity'),
        headers: _authHeader(),
      ),
      (body) async => kIsWeb
          ? (jsonDecode(body) as List)
              .map((e) => Activity.fromJson(e))
              .toList()
          : await parseJsonListInIsolate(body, Activity.fromJson),
      200,
    );
  }

  Future<Result<List<BookingApiModel>>> getBookings() async {
    return _send(
      (client) => client.get(
        Uri.http('$_host:$_port', '/booking'),
        headers: _authHeader(),
      ),
      (body) async => kIsWeb
          ? (jsonDecode(body) as List)
              .map((e) => BookingApiModel.fromJson(e))
              .toList()
          : await parseJsonListInIsolate(body, BookingApiModel.fromJson),
      200,
    );
  }

  Future<Result<BookingApiModel>> getBooking(int id) async {
    return _send(
      (client) => client.get(
        Uri.http('$_host:$_port', '/booking/$id'),
        headers: _authHeader(),
      ),
      (body) async => kIsWeb
          ? BookingApiModel.fromJson(
              jsonDecode(body) as Map<String, dynamic>,
            )
          : await parseJsonMapInIsolate(body, BookingApiModel.fromJson),
      200,
    );
  }

  Future<Result<BookingApiModel>> postBooking(BookingApiModel booking) async {
    return _send(
      (client) => client.post(
        Uri.http('$_host:$_port', '/booking'),
        headers: {..._authHeader(), 'Content-Type': 'application/json'},
        body: jsonEncode(booking),
      ),
      (body) async => kIsWeb
          ? BookingApiModel.fromJson(
              jsonDecode(body) as Map<String, dynamic>,
            )
          : await parseJsonMapInIsolate(body, BookingApiModel.fromJson),
      201,
    );
  }

  Future<Result<UserApiModel>> getUser() async {
    return _send(
      (client) => client.get(
        Uri.http('$_host:$_port', '/user'),
        headers: _authHeader(),
      ),
      (body) async => kIsWeb
          ? UserApiModel.fromJson(
              jsonDecode(body) as Map<String, dynamic>,
            )
          : await parseJsonMapInIsolate(body, UserApiModel.fromJson),
      200,
    );
  }

  Future<Result<void>> deleteBooking(int id) async {
    return _sendVoid(
      (client) => client.delete(
        Uri.http('$_host:$_port', '/booking/$id'),
        headers: _authHeader(),
      ),
      204,
    );
  }
}
