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

  Future<Result<List<Continent>>> getContinents() async {
    final client = _clientFactory();
    try {
      final uri = Uri.http('$_host:$_port', '/continent');
      final response = await client.get(uri, headers: _authHeader());
      if (response.statusCode == 200) {
        final stringData = utf8.decode(response.bodyBytes);
        final continents =
            kIsWeb
                ? (jsonDecode(stringData) as List)
                    .map((e) => Continent.fromJson(e))
                    .toList()
                : await parseJsonListInIsolate(stringData, Continent.fromJson);
        return Result.ok(continents);
      } else {
        return Result.error(Exception('Invalid response'));
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<List<Destination>>> getDestinations() async {
    final client = _clientFactory();
    try {
      final uri = Uri.http('$_host:$_port', '/destination');
      final response = await client.get(uri, headers: _authHeader());
      if (response.statusCode == 200) {
        final stringData = utf8.decode(response.bodyBytes);
        final destinations =
            kIsWeb
                ? (jsonDecode(stringData) as List)
                    .map((e) => Destination.fromJson(e))
                    .toList()
                : await parseJsonListInIsolate(
                  stringData,
                  Destination.fromJson,
                );
        return Result.ok(destinations);
      } else {
        return Result.error(Exception('Invalid response'));
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<List<Activity>>> getActivityByDestination(String ref) async {
    final client = _clientFactory();
    try {
      final uri = Uri.http('$_host:$_port', '/destination/$ref/activity');
      final response = await client.get(uri, headers: _authHeader());
      if (response.statusCode == 200) {
        final stringData = utf8.decode(response.bodyBytes);
        final activities =
            kIsWeb
                ? (jsonDecode(stringData) as List)
                    .map((e) => Activity.fromJson(e))
                    .toList()
                : await parseJsonListInIsolate(stringData, Activity.fromJson);
        return Result.ok(activities);
      } else {
        return Result.error(Exception('Invalid response'));
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<List<BookingApiModel>>> getBookings() async {
    final client = _clientFactory();
    try {
      final uri = Uri.http('$_host:$_port', '/booking');
      final response = await client.get(uri, headers: _authHeader());
      if (response.statusCode == 200) {
        final stringData = utf8.decode(response.bodyBytes);
        final bookings =
            kIsWeb
                ? (jsonDecode(stringData) as List)
                    .map((e) => BookingApiModel.fromJson(e))
                    .toList()
                : await parseJsonListInIsolate(
                  stringData,
                  BookingApiModel.fromJson,
                );
        return Result.ok(bookings);
      } else {
        return Result.error(Exception('Invalid response'));
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<BookingApiModel>> getBooking(int id) async {
    final client = _clientFactory();
    try {
      final uri = Uri.http('$_host:$_port', '/booking/$id');
      final response = await client.get(uri, headers: _authHeader());
      if (response.statusCode == 200) {
        final stringData = utf8.decode(response.bodyBytes);
        final booking =
            kIsWeb
                ? BookingApiModel.fromJson(
                  jsonDecode(stringData) as Map<String, dynamic>,
                )
                : await parseJsonMapInIsolate(
                  stringData,
                  BookingApiModel.fromJson,
                );
        return Result.ok(booking);
      } else {
        return Result.error(Exception('Invalid response'));
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<BookingApiModel>> postBooking(BookingApiModel booking) async {
    final client = _clientFactory();
    try {
      final uri = Uri.http('$_host:$_port', '/booking');
      final response = await client.post(
        uri,
        headers: {..._authHeader(), 'Content-Type': 'application/json'},
        body: jsonEncode(booking),
      );
      if (response.statusCode == 201) {
        final stringData = utf8.decode(response.bodyBytes);
        final booking =
            kIsWeb
                ? BookingApiModel.fromJson(
                  jsonDecode(stringData) as Map<String, dynamic>,
                )
                : await parseJsonMapInIsolate(
                  stringData,
                  BookingApiModel.fromJson,
                );
        return Result.ok(booking);
      } else {
        return Result.error(Exception('Invalid response'));
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<UserApiModel>> getUser() async {
    final client = _clientFactory();
    try {
      final uri = Uri.http('$_host:$_port', '/user');
      final response = await client.get(uri, headers: _authHeader());
      if (response.statusCode == 200) {
        final stringData = utf8.decode(response.bodyBytes);
        final user =
            kIsWeb
                ? UserApiModel.fromJson(
                  jsonDecode(stringData) as Map<String, dynamic>,
                )
                : await parseJsonMapInIsolate(
                  stringData,
                  UserApiModel.fromJson,
                );
        return Result.ok(user);
      } else {
        return Result.error(Exception('Invalid response'));
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }

  Future<Result<void>> deleteBooking(int id) async {
    final client = _clientFactory();
    try {
      final uri = Uri.http('$_host:$_port', '/booking/$id');
      final response = await client.delete(uri, headers: _authHeader());
      if (response.statusCode == 204) {
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
}
