import 'package:compass_app/config/dependencies.dart';
import 'package:compass_app/routing/router.dart';
import 'package:compass_app/ui/core/localization/app_strings.dart';
import 'package:compass_app/ui/core/localization/applocalization.dart';
import 'package:compass_app/ui/core/themes/theme.dart';
import 'package:compass_app/ui/core/ui/scroll_behavior.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../testing/fakes/repositories/fake_auth_repository.dart';

final locales = <Locale>[const Locale('en', 'US'), const Locale('pt', 'BR')];

final stringProviders = <Locale, AppStrings>{
  const Locale('en', 'US'): AppStringsEnUs(),
  const Locale('pt', 'BR'): AppStringsPtBr(),
};

Future<void> pumpMainAppWithLocale(WidgetTester tester, Locale locale) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: providersLocal,
      child: MaterialApp.router(
        locale: locale,
        localizationsDelegates: [
          ...GlobalMaterialLocalizations.delegates,
          AppLocalizationDelegate(),
        ],
        supportedLocales: const [Locale('en', 'US'), Locale('pt', 'BR')],
        scrollBehavior: AppCustomScrollBehavior(),
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: router(FakeAuthRepository()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
