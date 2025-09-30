// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:compass_app/routing/routes.dart';
import 'package:compass_app/ui/activities/view_models/activities_viewmodel.dart';
import 'package:compass_app/ui/activities/widgets/activities_header.dart';
import 'package:compass_app/ui/activities/widgets/activities_list.dart';
import 'package:compass_app/ui/activities/widgets/activities_title.dart';
import 'package:compass_app/ui/activities/widgets/activity_time_of_day.dart';
import 'package:compass_app/ui/core/localization/applocalization.dart';
import 'package:compass_app/ui/core/themes/dimens.dart';
import 'package:compass_app/ui/core/ui/error_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

const String confirmButtonKey = 'confirm-button';

class ActivitiesScreen extends HookConsumerWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(activitiesViewModelProvider.notifier);
    ref.watch(activitiesViewModelProvider);

    void listener() {
      if (viewModel.saveActivities.value.isSuccess) {
        viewModel.saveActivities.reset();
        context.go(Routes.booking);
      }

      if (viewModel.saveActivities.value.isFailure) {
        viewModel.saveActivities.reset();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalization.of(context).errorWhileSavingActivities),
            action: SnackBarAction(
              label: AppLocalization.of(context).tryAgain,
              onPressed: viewModel.saveActivities.execute,
            ),
          ),
        );
      }
    }

    useEffect(() {
      viewModel.saveActivities.addListener(listener);
      return () => viewModel.saveActivities.removeListener(listener);
    }, [viewModel]);

    useListenable(viewModel.loadActivities);
    useListenable(viewModel.saveActivities);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, r) {
        if (!didPop) context.go(Routes.results);
      },
      child: Scaffold(
        body: Builder(
          builder: (context) {
            if (viewModel.loadActivities.value.isRunning) {
              return Column(
                children: const [
                  ActivitiesHeader(),
                  Expanded(child: Center(child: CircularProgressIndicator())),
                ],
              );
            }
            if (viewModel.loadActivities.value.isFailure) {
              return Column(
                children: [
                  const ActivitiesHeader(),
                  Expanded(
                    child: Center(
                      child: ErrorIndicator(
                        title: AppLocalization.of(context)
                            .errorWhileLoadingActivities,
                        label: AppLocalization.of(context).tryAgain,
                        onPressed: viewModel.loadActivities.execute,
                      ),
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      const SliverToBoxAdapter(child: ActivitiesHeader()),
                      ActivitiesTitle(
                        viewModel: viewModel,
                        activityTimeOfDay: ActivityTimeOfDay.daytime,
                      ),
                      ActivitiesList(
                        viewModel: viewModel,
                        activityTimeOfDay: ActivityTimeOfDay.daytime,
                      ),
                      ActivitiesTitle(
                        viewModel: viewModel,
                        activityTimeOfDay: ActivityTimeOfDay.evening,
                      ),
                      ActivitiesList(
                        viewModel: viewModel,
                        activityTimeOfDay: ActivityTimeOfDay.evening,
                      ),
                    ],
                  ),
                ),
                _BottomArea(viewModel: viewModel),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BottomArea extends StatelessWidget {
  const _BottomArea({required this.viewModel});

  final ActivitiesViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return
    // SafeArea(
    //   child:
    Material(
      elevation: 8,
      child: Padding(
        padding: EdgeInsets.only(
          left: Dimens.of(context).paddingScreenHorizontal,
          right: Dimens.of(context).paddingScreenVertical,
          top: Dimens.paddingVertical,
          bottom: Dimens.of(context).paddingScreenVertical,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalization.of(
                context,
              ).selected(viewModel.selectedActivities.length),
              style: Theme.of(context).textTheme.labelLarge,
            ),
            FilledButton(
              key: const Key(confirmButtonKey),
              onPressed:
                  viewModel.selectedActivities.isNotEmpty
                      ? viewModel.saveActivities.execute
                      : null,
              child: Text(AppLocalization.of(context).confirm),
            ),
          ],
        ),
      ),
      // ),
    );
  }
}
