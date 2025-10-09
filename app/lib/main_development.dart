// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:compass_app/config/dependencies.dart';
import 'package:compass_app/main.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';

/// Development config entry point.
/// Launch with `flutter run --target lib/main_development.dart`.
/// Uses local data.
void main() {
  Logger.root.level = Level.ALL;

  runApp(ProviderScope(overrides: providersLocal, child: const MainApp()));
}
