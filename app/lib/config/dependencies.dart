// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:compass_app/data/repositories/activity/activity_repository.dart';
import 'package:compass_app/data/repositories/activity/local_activity_repository.dart';
import 'package:compass_app/data/repositories/activity/remote_activity_repository.dart';
import 'package:compass_app/data/repositories/auth/auth_repository.dart';
import 'package:compass_app/data/repositories/auth/dev_auth_repository.dart';
import 'package:compass_app/data/repositories/auth/remote_auth_repository.dart';
import 'package:compass_app/data/repositories/booking/booking_repository.dart';
import 'package:compass_app/data/repositories/booking/local_booking_repository.dart';
import 'package:compass_app/data/repositories/booking/remote_booking_repository.dart';
import 'package:compass_app/data/repositories/continent/continent_repository.dart';
import 'package:compass_app/data/repositories/continent/local_continent_repository.dart';
import 'package:compass_app/data/repositories/continent/remote_continent_repository.dart';
import 'package:compass_app/data/repositories/destination/destination_repository.dart';
import 'package:compass_app/data/repositories/destination/local_destination_repository.dart';
import 'package:compass_app/data/repositories/destination/remote_destination_repository.dart';
import 'package:compass_app/data/repositories/itinerary_config/itinerary_config_repository.dart';
import 'package:compass_app/data/repositories/itinerary_config/memory_itinerary_config_repository.dart';
import 'package:compass_app/data/repositories/user/local_user_repository.dart';
import 'package:compass_app/data/repositories/user/remote_user_repository.dart';
import 'package:compass_app/data/repositories/user/user_repository.dart';
import 'package:compass_app/data/services/api/api_client.dart';
import 'package:compass_app/data/services/api/auth_api_client.dart';
import 'package:compass_app/data/services/local/local_data_service.dart';
import 'package:compass_app/data/services/shared_preferences_service.dart';
import 'package:compass_app/domain/use_cases/booking/booking_create_use_case.dart';
import 'package:compass_app/domain/use_cases/booking/booking_share_use_case.dart';
import 'package:compass_app/ui/auth/auth_controller.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// API client for authentication requests.
final Provider<AuthApiClient> authApiClientProvider = Provider(
  (ref) => AuthApiClient(),
);

/// Generic API client.
final Provider<ApiClient> apiClientProvider = Provider((ref) => ApiClient());

/// Shared preferences service used to store tokens.
final Provider<SharedPreferencesService> sharedPreferencesServiceProvider =
    Provider((ref) => SharedPreferencesService());

/// Local data service used only in development.
final Provider<LocalDataService> localDataServiceProvider = Provider(
  (ref) => LocalDataService(),
);

/// Authentication repository used by the router to check login state.
/// Authentication repository used by [AuthController].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return RemoteAuthRepository(
    apiClient: ref.read(apiClientProvider),
    authApiClient: ref.read(authApiClientProvider),
    sharedPreferencesService: ref.read(sharedPreferencesServiceProvider),
  );
});

/// Authentication controller exposing the user's login state.
final authControllerProvider = AsyncNotifierProvider<AuthController, bool>(
  AuthController.new,
);

/// Destination repository implementation.
final destinationRepositoryProvider = Provider<DestinationRepository>((ref) {
  return RemoteDestinationRepository(apiClient: ref.read(apiClientProvider));
});

/// Continent repository implementation.
final continentRepositoryProvider = Provider<ContinentRepository>((ref) {
  return RemoteContinentRepository(apiClient: ref.read(apiClientProvider));
});

/// Activity repository implementation.
final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  return RemoteActivityRepository(apiClient: ref.read(apiClientProvider));
});

/// Itinerary configuration repository stored in memory.
final itineraryConfigRepositoryProvider = Provider<ItineraryConfigRepository>(
  (ref) {
    ref.keepAlive();
    return MemoryItineraryConfigRepository();
  },
);

/// Booking repository implementation.
final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  ref.keepAlive();
  return RemoteBookingRepository(apiClient: ref.read(apiClientProvider));
});

/// User repository implementation.
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return RemoteUserRepository(apiClient: ref.read(apiClientProvider));
});

/// Use case to create a booking.
final Provider<BookingCreateUseCase> bookingCreateUseCaseProvider = Provider(
  (ref) => BookingCreateUseCase(
    destinationRepository: ref.read(destinationRepositoryProvider),
    activityRepository: ref.read(activityRepositoryProvider),
    bookingRepository: ref.read(bookingRepositoryProvider),
  ),
);

/// Use case to share a booking.
final Provider<BookingShareUseCase> bookingShareUseCaseProvider = Provider(
  (ref) => BookingShareUseCase.withSharePlus(),
);

/// Overrides for local (development) configuration.
final providersLocal = <Override>[
  authRepositoryProvider.overrideWith((ref) => DevAuthRepository()),
  destinationRepositoryProvider.overrideWith(
    (ref) => LocalDestinationRepository(
      localDataService: ref.read(localDataServiceProvider),
    ),
  ),
  continentRepositoryProvider.overrideWith(
    (ref) => LocalContinentRepository(
      localDataService: ref.read(localDataServiceProvider),
    ),
  ),
  activityRepositoryProvider.overrideWith(
    (ref) => LocalActivityRepository(
      localDataService: ref.read(localDataServiceProvider),
    ),
  ),
  bookingRepositoryProvider.overrideWith(
    (ref) => LocalBookingRepository(
      localDataService: ref.read(localDataServiceProvider),
    ),
  ),
  userRepositoryProvider.overrideWith(
    (ref) => LocalUserRepository(
      localDataService: ref.read(localDataServiceProvider),
    ),
  ),
  itineraryConfigRepositoryProvider.overrideWithValue(
    MemoryItineraryConfigRepository(),
  ),
  localDataServiceProvider.overrideWithValue(LocalDataService()),
];

/// Overrides for remote (staging) configuration. Empty because remote is default.
final providersRemote = <Override>[
  itineraryConfigRepositoryProvider.overrideWithValue(
    MemoryItineraryConfigRepository(),
  ),
];
