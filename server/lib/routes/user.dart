// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../utils/response_utils.dart';

import '../config/constants.dart';

/// Implements a simple user API.
///
/// This API only returns a hardcoded user for demonstration purposes.
class UserApi {
  Router get router {
    final router = Router();

    router.get('/', (Request request) async {
      return jsonResponse(Constants.user);
    });

    return router;
  }
}
