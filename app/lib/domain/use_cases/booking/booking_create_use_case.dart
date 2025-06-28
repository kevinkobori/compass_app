import 'package:compass_app/data/repositories/activity/activity_repository.dart';
import 'package:compass_app/data/repositories/booking/booking_repository.dart';
import 'package:compass_app/data/repositories/destination/destination_repository.dart';
import 'package:compass_app/domain/models/booking/booking.dart';
import 'package:compass_app/domain/models/destination/destination.dart';
import 'package:compass_app/domain/models/itinerary_config/itinerary_config.dart';
import 'package:logging/logging.dart';
import 'package:result_dart/result_dart.dart';

class BookingCreateUseCase {
  BookingCreateUseCase({
    required DestinationRepository destinationRepository,
    required ActivityRepository activityRepository,
    required BookingRepository bookingRepository,
  }) : _destinationRepository = destinationRepository,
       _activityRepository = activityRepository,
       _bookingRepository = bookingRepository;

  final DestinationRepository _destinationRepository;
  final ActivityRepository _activityRepository;
  final BookingRepository _bookingRepository;
  final _log = Logger('BookingCreateUseCase');

  Future<Result<Booking>> createFrom(ItineraryConfig itineraryConfig) async {
    // Get Destination object from repository
    if (itineraryConfig.destination == null) {
      _log.warning('Destination is not set');
      return Failure(Exception('Destination is not set'));
    }

    final destinationResult = await _fetchDestination(
      itineraryConfig.destination!,
    );
    if (destinationResult.isError()) {
      _log.warning(
        'Error fetching destination: ${destinationResult.exceptionOrNull()}',
      );
      return Failure(
        destinationResult.exceptionOrNull() ??
            Exception('Unknown destination error'),
      );
    }
    final destination = destinationResult.getOrThrow();
    _log.fine('Destination loaded: ${destination.ref}');

    // Get Activity objects from repository
    if (itineraryConfig.activities.isEmpty) {
      _log.warning('Activities are not set');
      return Failure(Exception('Activities are not set'));
    }
    final activitiesResult = await _activityRepository.getByDestination(
      itineraryConfig.destination!,
    );
    if (activitiesResult.isError()) {
      _log.warning(
        'Error fetching activities: ${activitiesResult.exceptionOrNull()}',
      );
      return Failure(
        activitiesResult.exceptionOrNull() ??
            Exception('Unknown activities error'),
      );
    }
    final activitiesList = activitiesResult.getOrThrow();
    final activities =
        activitiesList
            .where(
              (activity) => itineraryConfig.activities.contains(activity.ref),
            )
            .toList();
    _log.fine('Activities loaded (${activities.length})');

    // Check if dates are set
    if (itineraryConfig.startDate == null || itineraryConfig.endDate == null) {
      _log.warning('Dates are not set');
      return Failure(Exception('Dates are not set'));
    }

    final booking = Booking(
      startDate: itineraryConfig.startDate!,
      endDate: itineraryConfig.endDate!,
      destination: destination,
      activity: activities,
    );

    final saveBookingResult = await _bookingRepository.createBooking(booking);
    if (saveBookingResult.isError()) {
      _log.warning(
        'Failed to save booking',
        saveBookingResult.exceptionOrNull(),
      );
      return Failure(
        saveBookingResult.exceptionOrNull() ??
            Exception('Failed to save booking'),
      );
    }
    _log.fine('Booking saved successfully');

    return Success(booking);
  }

  Future<Result<Destination>> _fetchDestination(String destinationRef) async {
    final result = await _destinationRepository.getDestinations();
    if (result.isError()) {
      return Failure(
        result.exceptionOrNull() ??
            Exception('Unknown destination fetch error'),
      );
    }
    final destinations = result.getOrThrow();
    try {
      final destination = destinations.firstWhere(
        (destination) => destination.ref == destinationRef,
      );
      return Success(destination);
    } catch (e) {
      return Failure(Exception('Destination not found'));
    }
  }
}
