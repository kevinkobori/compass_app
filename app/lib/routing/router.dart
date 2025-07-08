// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:compass_app/data/repositories/auth/auth_repository.dart';
import 'package:compass_app/routing/routes.dart';
import 'package:compass_app/ui/activities/view_models/activities_viewmodel.dart';
import 'package:compass_app/ui/activities/widgets/activities_screen.dart';
import 'package:compass_app/ui/auth/login/view_models/login_viewmodel.dart';
import 'package:compass_app/ui/auth/login/widgets/login_screen.dart';
import 'package:compass_app/ui/booking/view_models/booking_viewmodel.dart';
import 'package:compass_app/ui/booking/widgets/booking_screen.dart';
import 'package:compass_app/ui/home/view_models/home_viewmodel.dart';
import 'package:compass_app/ui/home/widgets/home_screen.dart';
import 'package:compass_app/ui/results/view_models/results_viewmodel.dart';
import 'package:compass_app/ui/results/widgets/results_screen.dart';
import 'package:compass_app/ui/search_form/view_models/search_form_viewmodel.dart';
import 'package:compass_app/ui/search_form/widgets/search_form_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Top go_router entry point.
///
/// Listens to changes in [AuthTokenRepository] to redirect the user
/// to /login when the user logs out.
typedef Reader = T Function<T>(ProviderListenable<T> provider);

final routerProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return GoRouter(
    initialLocation: Routes.home,
    debugLogDiagnostics: true,
    redirect: (context, state) => _redirect(context, state, ref.read),
    refreshListenable: authRepository,
    routes: [
    GoRoute(
      path: Routes.login,
      builder: (context, state) {
        final viewModel =
            LoginViewModel(authRepository: context.read(authRepositoryProvider));
        return LoginScreen(viewModel: viewModel);
      },
    ),
    GoRoute(
      path: Routes.home,
      builder: (context, state) {
        final viewModel = HomeViewModel(
          bookingRepository: context.read(bookingRepositoryProvider),
          userRepository: context.read(userRepositoryProvider),
        );
        return HomeScreen(viewModel: viewModel);
      },
      routes: [
        GoRoute(
          path: Routes.searchRelative,
          builder: (context, state) {
            final viewModel = SearchFormViewModel(
              continentRepository: context.read(continentRepositoryProvider),
              itineraryConfigRepository:
                  context.read(itineraryConfigRepositoryProvider),
            );
            return SearchFormScreen(viewModel: viewModel);
          },
        ),
        GoRoute(
          path: Routes.resultsRelative,
          builder: (context, state) {
            final viewModel = ResultsViewModel(
              destinationRepository: context.read(destinationRepositoryProvider),
              itineraryConfigRepository:
                  context.read(itineraryConfigRepositoryProvider),
            );
            return ResultsScreen(viewModel: viewModel);
          },
        ),
        GoRoute(
          path: Routes.activitiesRelative,
          builder: (context, state) {
            final viewModel = ActivitiesViewModel(
              activityRepository: context.read(activityRepositoryProvider),
              itineraryConfigRepository:
                  context.read(itineraryConfigRepositoryProvider),
            );
            return ActivitiesScreen(viewModel: viewModel);
          },
        ),
        GoRoute(
          path: Routes.bookingRelative,
          builder: (context, state) {
            final viewModel = BookingViewModel(
              itineraryConfigRepository:
                  context.read(itineraryConfigRepositoryProvider),
              createBookingUseCase:
                  context.read(bookingCreateUseCaseProvider),
              shareBookingUseCase:
                  context.read(bookingShareUseCaseProvider),
              bookingRepository: context.read(bookingRepositoryProvider),
            );

            // When opening the booking screen directly
            // create a new booking from the stored ItineraryConfig.
            viewModel.createBooking.execute();

            return BookingScreen(viewModel: viewModel);
          },
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                final viewModel = BookingViewModel(
                  itineraryConfigRepository:
                      context.read(itineraryConfigRepositoryProvider),
                  createBookingUseCase:
                      context.read(bookingCreateUseCaseProvider),
                  shareBookingUseCase:
                      context.read(bookingShareUseCaseProvider),
                  bookingRepository: context.read(bookingRepositoryProvider),
                );

                // When opening the booking screen with an existing id
                // load and display that booking.
                viewModel.loadBooking.execute(id);

                return BookingScreen(viewModel: viewModel);
              },
            ),
          ],
        ),
      ],
    ),
  ],
  );
});

// From https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/redirection.dart
Future<String?> _redirect(
  BuildContext context,
  GoRouterState state,
  Reader read,
) async {
  // if the user is not logged in, they need to login
  final loggedIn = await read(authRepositoryProvider).isAuthenticated;
  final loggingIn = state.matchedLocation == Routes.login;
  if (!loggedIn) {
    return Routes.login;
  }

  // if the user is logged in but still on the login page, send them to
  // the home page
  if (loggingIn) {
    return Routes.home;
  }

  // no need to redirect at all
  return null;
}
