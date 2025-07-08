// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:compass_app/domain/models/activity/activity.dart';
import 'package:compass_app/ui/booking/view_models/booking_viewmodel.dart';
import 'package:compass_app/ui/booking/widgets/booking_header.dart';
import 'package:compass_app/ui/core/themes/dimens.dart';
import 'package:compass_app/utils/image_error_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class BookingBody extends HookWidget {
  const BookingBody({required this.viewModel, super.key});

  final BookingViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    // Rebuild the widget whenever the view model notifies listeners.
    useListenable(viewModel);

    final booking = viewModel.booking;
    if (booking == null) return const SizedBox();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: BookingHeader(booking: booking)),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final activity = booking.activity[index];
            return _Activity(activity: activity);
          }, childCount: booking.activity.length),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 200)),
      ],
    );
  }
}

class _Activity extends StatelessWidget {
  const _Activity({required this.activity});

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: Dimens.paddingVertical,
        left: Dimens.of(context).paddingScreenHorizontal,
        right: Dimens.of(context).paddingScreenHorizontal,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: activity.imageUrl,
              height: 80,
              width: 80,
              errorListener: imageErrorListener,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.timeOfDay.name.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                Text(
                  activity.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  activity.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
