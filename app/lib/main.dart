// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:compass_app/main_development.dart' as development;
import 'package:compass_app/routing/router.dart';
import 'package:compass_app/ui/core/localization/applocalization.dart';
import 'package:compass_app/ui/core/themes/theme.dart';
import 'package:compass_app/ui/core/ui/scroll_behavior.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Default main method
void main() {
  // Launch development config by default
  development.main();
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      localizationsDelegates: [
        ...GlobalMaterialLocalizations.delegates,
        AppLocalizationDelegate(),
      ],
      // locale: Locale('en', 'US'),
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('en', 'US'), Locale('pt', 'BR')],
      scrollBehavior: AppCustomScrollBehavior(),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
