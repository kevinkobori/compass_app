// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../domain/models/activity/activity.dart';
import '../../../domain/models/continent/continent.dart';
import '../../../domain/models/destination/destination.dart';
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
        final json = jsonDecode(response.body) as List<dynamic>;
        return Result.ok(
          json.map((e) => Continent.fromJson(e)).toList(),
        );
      } else {
        return const Result.error(Exception('Invalid response'));
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
        final json = jsonDecode(response.body) as List<dynamic>;
        return Result.ok(
          json.map((e) => Destination.fromJson(e)).toList(),
        );
      } else {
        return const Result.error(Exception('Invalid response'));
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
        final json = jsonDecode(response.body) as List<dynamic>;
        return Result.ok(
          json.map((e) => Activity.fromJson(e)).toList(),
        );
      } else {
        return const Result.error(Exception('Invalid response'));
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
        final json = jsonDecode(response.body) as List<dynamic>;
        return Result.ok(
          json.map((e) => BookingApiModel.fromJson(e)).toList(),
        );
      } else {
        return const Result.error(Exception('Invalid response'));
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
        final booking = BookingApiModel.fromJson(jsonDecode(response.body));
        return Result.ok(booking);
      } else {
        return const Result.error(Exception('Invalid response'));
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
        headers: {
          ..._authHeader(),
          'Content-Type': 'application/json',
        },
        body: jsonEncode(booking),
      );
      if (response.statusCode == 201) {
        final result = BookingApiModel.fromJson(jsonDecode(response.body));
        return Result.ok(result);
      } else {
        return const Result.error(Exception('Invalid response'));
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
        final user = UserApiModel.fromJson(jsonDecode(response.body));
        return Result.ok(user);
      } else {
        return const Result.error(Exception('Invalid response'));
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
        return const Result.error(Exception('Invalid response'));
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      client.close();
    }
  }
}
