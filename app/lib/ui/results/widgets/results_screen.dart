// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:compass_app/routing/routes.dart';
import 'package:compass_app/ui/core/localization/applocalization.dart';
import 'package:compass_app/ui/core/themes/dimens.dart';
import 'package:compass_app/ui/core/ui/error_indicator.dart';
import 'package:compass_app/ui/core/ui/search_bar.dart';
import 'package:compass_app/ui/results/view_models/results_viewmodel.dart';
import 'package:compass_app/ui/results/widgets/result_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

class ResultsScreen extends HookConsumerWidget {
  const ResultsScreen({required this.viewModel, super.key});

  final ResultsViewModel viewModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void listener() {
      if (viewModel.updateItineraryConfig.value.isSuccess) {
        viewModel.updateItineraryConfig.reset();
        context.go(Routes.activities);
      }

      if (viewModel.updateItineraryConfig.value.isFailure) {
        viewModel.updateItineraryConfig.reset();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalization.of(context).errorWhileSavingItinerary),
          ),
        );
      }
    }

    useEffect(() {
      viewModel.updateItineraryConfig.addListener(listener);
      return () => viewModel.updateItineraryConfig.removeListener(listener);
    }, [viewModel]);

    useListenable(viewModel);
    useListenable(viewModel.search);
    useListenable(viewModel.updateItineraryConfig);

    return PopScope(
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, r) {
        if (!didPop) context.go(Routes.search);
      },
      child: Scaffold(
        body: Builder(
          builder: (context) {
            if (viewModel.search.value.isRunning) {
              return Column(
                children: [
                  _AppSearchBar(viewModel: viewModel),
                  Expanded(child: Center(child: CircularProgressIndicator())),
                ],
              );
            }
            if (viewModel.search.value.isFailure) {
              return Column(
                children: [
                  _AppSearchBar(viewModel: viewModel),
                  Expanded(
                    child: Center(
                      child: ErrorIndicator(
                        title: AppLocalization.of(context)
                            .errorWhileLoadingDestinations,
                        label: AppLocalization.of(context).tryAgain,
                        onPressed: viewModel.search.execute,
                      ),
                    ),
                  ),
                ],
              );
            }

            return Padding(
              padding: Dimens.of(context).edgeInsetsScreenHorizontal,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _AppSearchBar(viewModel: viewModel)),
                  _Grid(viewModel: viewModel),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AppSearchBar extends StatelessWidget {
  const _AppSearchBar({required this.viewModel});

  final ResultsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.only(
          top: Dimens.of(context).paddingScreenVertical,
          bottom: Dimens.mobile.paddingScreenVertical,
        ),
        child: AppSearchBar(
          config: viewModel.config,
          // onTap: () {
          //   // Navigate to SearchFormScreen and edit search
          // context.pop();
          // },
        ),
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.viewModel});

  final ResultsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 182 / 222,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        final destination = viewModel.destinations[index];
        return ResultCard(
          key: ValueKey(destination.ref),
          destination: destination,
          onTap: () {
            viewModel.updateItineraryConfig.execute(destination.ref);
          },
        );
      }, childCount: viewModel.destinations.length),
    );
  }
}
