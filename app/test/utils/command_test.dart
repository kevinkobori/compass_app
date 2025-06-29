// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:result_command/result_command.dart';
import 'package:result_dart/result_dart.dart';

void main() {
  group('Command0 tests', () {
    test('should complete void command', () async {
      // Void action
      final command = Command0<Unit>(() => Future.value(const Success(unit)));

      // Run void action
      await command.execute();

      // Action completed
      expect(command.value.isSuccess, true);
    });

    test('should complete bool command', () async {
      // Action that returns bool
      final command = Command0<bool>(() => Future.value(const Success(true)));

      // Run action with result
      await command.execute();

      // Action completed
      expect(command.value.isSuccess, true);
      // expect(command.result!.getOrThrow(), true);
    });

    test('running should be true', () async {
      final command = Command0<Unit>(() => Future.value(const Success(unit)));
      final future = command.execute();

      // Action is running
      expect(command.value.isRunning, true);

      // Await execution
      await future;

      // Action finished running
      expect(command.value.isRunning, false);
    });

    test('should only run once', () async {
      var count = 0;
      final command = Command0<int>(() => Future.value(Success(count++)));
      final future = command.execute();

      // Run multiple times
      unawaited(command.execute());
      unawaited(command.execute());
      unawaited(command.execute());
      unawaited(command.execute());

      // Await execution
      await future;

      // Action is called once
      expect(count, 1);
    });

    test('should handle errors', () async {
      final command = Command0<int>(
        () => Future.value(Failure(Exception('ERROR!'))),
      );
      await command.execute();
      expect(command.value.isFailure, true);
    });
  });

  group('Command1 tests', () {
    test('should complete void command, bool argument', () async {
      // Void action with bool argument
      final command = Command1<Unit, bool>((a) {
        expect(a, true);
        return Future.value(const Success(unit));
      });

      // Run void action, ignore void return
      await command.execute(true);

      expect(command.value.isSuccess, true);
    });

    test('should complete bool command, bool argument', () async {
      // Action that returns bool argument
      final command = Command1<bool, bool>(
        (a) => Future.value(const Success(true)),
      );

      // Run action with result and argument
      await command.execute(true);

      // Argument was passed to onComplete
      expect(command.value.isSuccess, true);
      // expect(command.result!.getOrThrow(), true);
    });
  });
}
