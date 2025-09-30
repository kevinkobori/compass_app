// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:compass_app/routing/routes.dart';
import 'package:compass_app/ui/core/themes/dimens.dart';
import 'package:compass_app/ui/core/ui/search_bar.dart';
import 'package:compass_app/ui/results/widgets/results_screen.dart';
import 'package:compass_app/ui/search_form/view_models/search_form_viewmodel.dart';
import 'package:compass_app/ui/search_form/widgets/search_form_continent.dart';
import 'package:compass_app/ui/search_form/widgets/search_form_date.dart';
import 'package:compass_app/ui/search_form/widgets/search_form_guests.dart';
import 'package:compass_app/ui/search_form/widgets/search_form_submit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Search form screen
///
/// Displays a search form with continent, date and guests selection.
/// Tapping on the submit button opens the [ResultsScreen] screen
/// passing the search options as query parameters.
class SearchFormScreen extends HookConsumerWidget {
  const SearchFormScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(searchFormViewModelProvider.notifier);
    ref.watch(searchFormViewModelProvider);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, r) {
        if (!didPop) context.go(Routes.home);
      },
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.only(
                  top: Dimens.of(context).paddingScreenVertical,
                  left: Dimens.of(context).paddingScreenHorizontal,
                  right: Dimens.of(context).paddingScreenHorizontal,
                  bottom: Dimens.paddingVertical,
                ),
                child: const AppSearchBar(),
              ),
            ),
            SearchFormContinent(viewModel: viewModel),
            SearchFormDate(viewModel: viewModel),
            SearchFormGuests(viewModel: viewModel),
            const Spacer(),
            SearchFormSubmit(viewModel: viewModel),
          ],
        ),
      ),
    );
  }
}
