// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:logging/logging.dart';
import 'package:result_dart/result_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static const _tokenKey = 'TOKEN';
  final _log = Logger('SharedPreferencesService');

  Future<Result<String>> fetchToken() async {
    try {
      final sharedPreferences = await SharedPreferences.getInstance();
      _log.finer('Got token from SharedPreferences');
      final token = sharedPreferences.getString(_tokenKey);
      if (token != null) {
        return Success(token);
      } else {
        return Failure(Exception('Token not found'));
      }
    } on Exception catch (e) {
      _log.warning('Failed to get token', e);
      return Failure(e);
    }
  }

  Future<Result<Unit>> saveToken(String? token) async {
    try {
      final sharedPreferences = await SharedPreferences.getInstance();
      if (token == null) {
        _log.finer('Removed token');
        await sharedPreferences.remove(_tokenKey);
      } else {
        _log.finer('Replaced token');
        await sharedPreferences.setString(_tokenKey, token);
      }
      return const Success(unit);
    } on Exception catch (e) {
      _log.warning('Failed to set token', e);
      return Failure(e);
    }
  }
}
