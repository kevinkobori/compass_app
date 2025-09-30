// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:compass_app/routing/routes.dart';
import 'package:compass_app/ui/core/localization/applocalization.dart';
import 'package:compass_app/ui/core/themes/dimens.dart';
import 'package:compass_app/ui/results/widgets/results_screen.dart';
import 'package:compass_app/ui/search_form/view_models/search_form_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const String searchFormSubmitButtonKey = 'submit-button';

/// Search form submit button
///
/// The button is disabled when the form is data is incomplete.
/// When tapped, it navigates to the [ResultsScreen]
/// passing the search options as query parameters.
class SearchFormSubmit extends StatefulWidget {
  const SearchFormSubmit({required this.viewModel, super.key});

  final SearchFormViewModel viewModel;

  @override
  State<SearchFormSubmit> createState() => _SearchFormSubmitState();
}

class _SearchFormSubmitState extends State<SearchFormSubmit> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.updateItineraryConfig.addListener(_onResult);
  }

  @override
  void didUpdateWidget(covariant SearchFormSubmit oldWidget) {
    oldWidget.viewModel.updateItineraryConfig.removeListener(_onResult);
    widget.viewModel.updateItineraryConfig.addListener(_onResult);
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.viewModel.updateItineraryConfig.removeListener(_onResult);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: Dimens.paddingVertical,
        left: Dimens.of(context).paddingScreenHorizontal,
        right: Dimens.of(context).paddingScreenHorizontal,
        bottom: Dimens.of(context).paddingScreenVertical,
      ),
      child: ListenableBuilder(
        listenable: widget.viewModel,
        child: SizedBox(
          height: 52,
          child: Center(child: Text(AppLocalization.of(context).search)),
        ),
        builder: (context, child) {
          return FilledButton(
            key: const ValueKey(searchFormSubmitButtonKey),
            onPressed:
                widget.viewModel.valid
                    ? widget.viewModel.updateItineraryConfig.execute
                    : null,
            child: child,
          );
        },
      ),
    );
  }

  void _onResult() {
    if (widget.viewModel.updateItineraryConfig.value.isSuccess) {
      widget.viewModel.updateItineraryConfig.reset();
      context.go(Routes.results);
    }

    if (widget.viewModel.updateItineraryConfig.value.isFailure) {
      widget.viewModel.updateItineraryConfig.reset();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalization.of(context).errorWhileSavingItinerary),
          action: SnackBarAction(
            label: AppLocalization.of(context).tryAgain,
            onPressed: widget.viewModel.updateItineraryConfig.execute,
          ),
        ),
      );
    }
  }
}
