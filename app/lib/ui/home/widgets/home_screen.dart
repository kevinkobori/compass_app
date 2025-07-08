// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:compass_app/domain/models/booking/booking_summary.dart';
import 'package:compass_app/routing/routes.dart';
import 'package:compass_app/ui/core/localization/applocalization.dart';
import 'package:compass_app/ui/core/themes/colors.dart';
import 'package:compass_app/ui/core/themes/dimens.dart';
import 'package:compass_app/ui/core/ui/date_format_start_end.dart';
import 'package:compass_app/ui/core/ui/error_indicator.dart';
import 'package:compass_app/ui/home/view_models/home_viewmodel.dart';
import 'package:compass_app/ui/home/widgets/home_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';

const String bookingButtonKey = 'booking-button';

class HomeScreen extends HookWidget {
  const HomeScreen({required this.viewModel, super.key});

  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    void onResult() {
      if (viewModel.deleteBooking.value.isSuccess) {
        viewModel.deleteBooking.reset();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalization.of(context).bookingDeleted)),
        );
      }

      if (viewModel.deleteBooking.value.isFailure) {
        viewModel.deleteBooking.reset();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalization.of(context).errorWhileDeletingBooking),
          ),
        );
      }
    }

    useEffect(() {
      viewModel.deleteBooking.addListener(onResult);
      return () => viewModel.deleteBooking.removeListener(onResult);
    }, [viewModel]);

    useListenable(viewModel);
    useListenable(viewModel.load);
    useListenable(viewModel.deleteBooking);

    final Widget body;
    if (viewModel.load.value.isRunning) {
      body = const Center(child: CircularProgressIndicator());
    } else if (viewModel.load.value.isFailure) {
      body = ErrorIndicator(
        title: AppLocalization.of(context).errorWhileLoadingHome,
        label: AppLocalization.of(context).tryAgain,
        onPressed: viewModel.load.execute,
      );
    } else {
      body = CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: Dimens.of(context).paddingScreenVertical,
                horizontal: Dimens.of(context).paddingScreenHorizontal,
              ),
              child: HomeHeader(viewModel: viewModel),
            ),
          ),
          SliverList.builder(
            itemCount: viewModel.bookings.length,
            itemBuilder: (_, index) => _Booking(
              key: ValueKey(viewModel.bookings[index].id),
              booking: viewModel.bookings[index],
              onTap: () => context.push(
                Routes.bookingWithId(
                  viewModel.bookings[index].id,
                ),
              ),
              confirmDismiss: (_) async {
                // Wait for the command to complete
                await viewModel.deleteBooking.execute(
                  viewModel.bookings[index].id,
                );
                // Remove the item if the delete command succeeded
                return viewModel.deleteBooking.value.isSuccess;
              },
            ),
          ),
        ],
      );
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        // Workaround for https://github.com/flutter/flutter/issues/115358#issuecomment-2117157419
        heroTag: null,
        key: const ValueKey(bookingButtonKey),
        onPressed: () => context.go(Routes.search),
        label: Text(AppLocalization.of(context).bookNewTrip),
        icon: const Icon(Icons.add_location_outlined),
      ),
      body: SafeArea(child: body),
    );
  }
}

class _Booking extends StatelessWidget {
  const _Booking({
    required this.booking,
    required this.onTap,
    required this.confirmDismiss,
    super.key,
  });

  final BookingSummary booking;
  final GestureTapCallback onTap;
  final ConfirmDismissCallback confirmDismiss;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(booking.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: confirmDismiss,
      background: const ColoredBox(
        color: AppColors.grey1,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.only(right: Dimens.paddingHorizontal),
              child: Icon(Icons.delete),
            ),
          ],
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Dimens.of(context).paddingScreenHorizontal,
            vertical: Dimens.paddingVertical,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(booking.name, style: Theme.of(context).textTheme.titleLarge),
              Text(
                dateFormatStartEnd(
                  DateTimeRange(start: booking.startDate, end: booking.endDate),
                ),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
