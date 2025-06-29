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
import 'package:go_router/go_router.dart';

const String confirmButtonKey = 'confirm-button';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({required this.viewModel, super.key});

  final ActivitiesViewModel viewModel;

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.saveActivities.addListener(_onResult);
  }

  @override
  void didUpdateWidget(covariant ActivitiesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.viewModel.saveActivities.removeListener(_onResult);
    widget.viewModel.saveActivities.addListener(_onResult);
  }

  @override
  void dispose() {
    widget.viewModel.saveActivities.removeListener(_onResult);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, r) {
        if (!didPop) context.go(Routes.results);
      },
      child: Scaffold(
        body: ListenableBuilder(
          listenable: widget.viewModel.loadActivities,
          builder: (context, child) {
            if (widget.viewModel.loadActivities.value.isSuccess) {
              // The getter 'completed' isn't defined for the type
              // 'Command0<Object>'.
              // Try importing the library that defines 'completed', correcting
              // the name to the name of an existing getter, or defining a
              // getter or field named 'completed'.
              return child!;
            }
            return Column(
              children: [
                const ActivitiesHeader(),
                if (widget.viewModel.loadActivities.value.isRunning)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (widget.viewModel.loadActivities.value.isFailure)
                  Expanded(
                    child: Center(
                      child: ErrorIndicator(
                        title:
                            AppLocalization.of(
                              context,
                            ).errorWhileLoadingActivities,
                        label: AppLocalization.of(context).tryAgain,
                        onPressed: widget.viewModel.loadActivities.execute,
                      ),
                    ),
                  ),
              ],
            );
          },
          child: ListenableBuilder(
            listenable: widget.viewModel,
            builder: (context, child) {
              return Column(
                children: [
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        const SliverToBoxAdapter(child: ActivitiesHeader()),
                        ActivitiesTitle(
                          viewModel: widget.viewModel,
                          activityTimeOfDay: ActivityTimeOfDay.daytime,
                        ),
                        ActivitiesList(
                          viewModel: widget.viewModel,
                          activityTimeOfDay: ActivityTimeOfDay.daytime,
                        ),
                        ActivitiesTitle(
                          viewModel: widget.viewModel,
                          activityTimeOfDay: ActivityTimeOfDay.evening,
                        ),
                        ActivitiesList(
                          viewModel: widget.viewModel,
                          activityTimeOfDay: ActivityTimeOfDay.evening,
                        ),
                      ],
                    ),
                  ),
                  _BottomArea(viewModel: widget.viewModel),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _onResult() {
    if (widget.viewModel.saveActivities.value.isSuccess) {
      widget.viewModel.saveActivities.reset();
      context.go(Routes.booking);
    }

    if (widget.viewModel.saveActivities.value.isFailure) {
      widget.viewModel.saveActivities.reset();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalization.of(context).errorWhileSavingActivities),
          action: SnackBarAction(
            label: AppLocalization.of(context).tryAgain,
            onPressed: widget.viewModel.saveActivities.execute,
          ),
        ),
      );
    }
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
