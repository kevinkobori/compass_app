// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:compass_app/routing/routes.dart';
import 'package:compass_app/ui/booking/view_models/booking_viewmodel.dart';
import 'package:compass_app/ui/booking/widgets/booking_body.dart';
import 'package:compass_app/ui/core/localization/applocalization.dart';
import 'package:compass_app/ui/core/ui/error_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class BookingScreen extends HookConsumerWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(bookingViewModelProvider.notifier);
    final booking = ref.watch(bookingViewModelProvider);

    void listener() {
      if (viewModel.shareBooking.value.isFailure) {
        viewModel.shareBooking.reset();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalization.of(context).errorWhileSharing),
            action: SnackBarAction(
              label: AppLocalization.of(context).tryAgain,
              onPressed: viewModel.shareBooking.execute,
            ),
          ),
        );
      }
    }

    useEffect(() {
      viewModel.shareBooking.addListener(listener);
      return () => viewModel.shareBooking.removeListener(listener);
    }, [viewModel]);

    useListenable(viewModel.createBooking);
    useListenable(viewModel.loadBooking);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, r) {
        if (!didPop) context.go(Routes.home);
      },
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          heroTag:
              null, // Workaround for https://github.com/flutter/flutter/issues/115358#issuecomment-2117157419
          key: const ValueKey('share-button'),
          onPressed:
              booking != null ? viewModel.shareBooking.execute : null,
          label: Text(AppLocalization.of(context).shareTrip),
          icon: const Icon(Icons.share_outlined),
        ),
        body: Builder(
          builder: (context) {
            if (viewModel.createBooking.value.isRunning ||
                viewModel.loadBooking.value.isRunning) {
              return const Center(child: CircularProgressIndicator());
            }
            if (viewModel.createBooking.value.isFailure) {
              return Center(
                child: ErrorIndicator(
                  title: AppLocalization.of(context).errorWhileLoadingBooking,
                  label: AppLocalization.of(context).tryAgain,
                  onPressed: viewModel.createBooking.execute,
                ),
              );
            }
            if (viewModel.loadBooking.value.isFailure) {
              return Center(
                child: ErrorIndicator(
                  title: AppLocalization.of(context).errorWhileLoadingBooking,
                  label: AppLocalization.of(context).close,
                  onPressed: () => context.go(Routes.home),
                ),
              );
            }
            return BookingBody(viewModel: viewModel);
          },
        ),
      ),
    );
  }
}
