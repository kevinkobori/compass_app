// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:compass_app/ui/activities/view_models/activities_viewmodel.dart';
import 'package:compass_app/ui/activities/widgets/activity_time_of_day.dart';
import 'package:compass_app/ui/core/localization/applocalization.dart';
import 'package:compass_app/ui/core/themes/dimens.dart';
import 'package:flutter/material.dart';

class ActivitiesTitle extends StatelessWidget {
  const ActivitiesTitle({
    required this.activityTimeOfDay,
    required this.viewModel,
    super.key,
  });

  final ActivitiesViewModel viewModel;
  final ActivityTimeOfDay activityTimeOfDay;

  @override
  Widget build(BuildContext context) {
    final list = switch (activityTimeOfDay) {
      ActivityTimeOfDay.daytime => viewModel.daytimeActivities,
      ActivityTimeOfDay.evening => viewModel.eveningActivities,
    };
    if (list.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox());
    }
    return SliverToBoxAdapter(
      child: Padding(
        padding: Dimens.of(context).edgeInsetsScreenHorizontal,
        child: Text(_label(context)),
      ),
    );
  }

  String _label(BuildContext context) => switch (activityTimeOfDay) {
    ActivityTimeOfDay.daytime => AppLocalization.of(context).daytime,
    ActivityTimeOfDay.evening => AppLocalization.of(context).evening,
  };
}
