// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:compass_app/ui/core/localization/app_strings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalization {
  AppLocalization(this.locale) {
    switch (locale.toString()) {
      case 'pt_BR':
        _strings = AppStringsPtBr();
      case 'en_US':
      default:
        _strings = AppStringsEnUs();
    }
  }
  final Locale locale;
  late final AppStrings _strings;

  static AppLocalization of(BuildContext context) {
    return Localizations.of(context, AppLocalization)!;
  }

  // Getters delegando para a classe interna
  String get activities => _strings.activities;
  String get addDates => _strings.addDates;
  String get bookingDeleted => _strings.bookingDeleted;
  String get bookNewTrip => _strings.bookNewTrip;
  String get close => _strings.close;
  String get confirm => _strings.confirm;
  String get daytime => _strings.daytime;
  String get errorWhileDeletingBooking => _strings.errorWhileDeletingBooking;
  String get errorWhileLoadingActivities =>
      _strings.errorWhileLoadingActivities;
  String get errorWhileLoadingBooking => _strings.errorWhileLoadingBooking;
  String get errorWhileLoadingContinents =>
      _strings.errorWhileLoadingContinents;
  String get errorWhileLoadingDestinations =>
      _strings.errorWhileLoadingDestinations;
  String get errorWhileLoadingHome => _strings.errorWhileLoadingHome;
  String get errorWhileLogin => _strings.errorWhileLogin;
  String get errorWhileLogout => _strings.errorWhileLogout;
  String get errorWhileSavingActivities => _strings.errorWhileSavingActivities;
  String get errorWhileSavingItinerary => _strings.errorWhileSavingItinerary;
  String get errorWhileSharing => _strings.errorWhileSharing;
  String get evening => _strings.evening;
  String get login => _strings.login;
  String nameTrips(String name) => _strings.nameTrips(name);
  String get save => _strings.save;
  String get search => _strings.search;
  String get searchDestination => _strings.searchDestination;
  String selected(int value) => _strings.selected(value);
  String get shareTrip => _strings.shareTrip;
  String get tryAgain => _strings.tryAgain;
  String get when => _strings.when;
  String get who => _strings.who;
  String get yourChosenActivities => _strings.yourChosenActivities;
}

class AppLocalizationDelegate extends LocalizationsDelegate<AppLocalization> {
  @override
  bool isSupported(Locale locale) => ['en', 'pt'].contains(locale.languageCode);

  @override
  Future<AppLocalization> load(Locale locale) {
    return SynchronousFuture(AppLocalization(locale));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalization> old) =>
      false;
}
