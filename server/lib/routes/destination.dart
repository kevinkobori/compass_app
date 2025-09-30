// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../config/assets.dart';
import '../utils/response_utils.dart';

class DestinationApi {
  Router get router {
    final router = Router();

    router.get('/', (Request request) {
      return jsonResponse(Assets.destinations);
    });

    router.get('/<id>/activity', (Request request, String id) {
      final list =
          Assets.activities
              .where((activity) => activity.destinationRef == id)
              .toList();
      return jsonResponse(list);
    });

    return router;
  }
}
