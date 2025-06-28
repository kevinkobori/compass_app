import 'package:compass_app/data/repositories/booking/booking_repository.dart';
import 'package:compass_app/data/services/api/api_client.dart';
import 'package:compass_app/data/services/api/model/booking/booking_api_model.dart';
import 'package:compass_app/domain/models/booking/booking.dart';
import 'package:compass_app/domain/models/booking/booking_summary.dart';
import 'package:compass_app/domain/models/destination/destination.dart';
import 'package:result_dart/result_dart.dart';

class BookingRepositoryRemote implements BookingRepository {
  BookingRepositoryRemote({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  List<Destination>? _cachedDestinations;

  @override
  Future<Result<Unit>> createBooking(Booking booking) async {
    try {
      final bookingApiModel = BookingApiModel(
        startDate: booking.startDate,
        endDate: booking.endDate,
        name: '${booking.destination.name}, ${booking.destination.continent}',
        destinationRef: booking.destination.ref,
        activitiesRef:
            booking.activity.map((activity) => activity.ref).toList(),
      );
      final result = await _apiClient.postBooking(bookingApiModel);
      return result.map((_) => unit); // converte o resultado para Unit
    } on Exception catch (e) {
      return Failure(e);
    }
  }

  @override
  Future<Result<Booking>> getBooking(int id) async {
    try {
      // Get booking by ID from server
      final resultBooking = await _apiClient.getBooking(id);
      if (resultBooking.isError()) {
        return Failure(
          resultBooking.exceptionOrNull() ?? Exception('Unknown booking error'),
        );
      }
      final booking = resultBooking.getOrThrow();

      // Load destinations if not loaded yet
      if (_cachedDestinations == null) {
        final resultDestination = await _apiClient.getDestinations();
        if (resultDestination.isError()) {
          return Failure(
            resultDestination.exceptionOrNull() ??
                Exception('Unknown destination error'),
          );
        }
        _cachedDestinations = resultDestination.getOrThrow();
      }

      // Get destination for booking
      final destination = _cachedDestinations!.firstWhere(
        (destination) => destination.ref == booking.destinationRef,
        orElse: () => throw Exception('Destination not found'),
      );

      final resultActivities = await _apiClient.getActivityByDestination(
        destination.ref,
      );
      if (resultActivities.isError()) {
        return Failure(
          resultActivities.exceptionOrNull() ??
              Exception('Unknown activity error'),
        );
      }
      final activities =
          resultActivities
              .getOrThrow()
              .where((activity) => booking.activitiesRef.contains(activity.ref))
              .toList();

      return Success(
        Booking(
          id: booking.id,
          startDate: booking.startDate,
          endDate: booking.endDate,
          destination: destination,
          activity: activities,
        ),
      );
    } on Exception catch (e) {
      return Failure(e);
    }
  }

  @override
  Future<Result<List<BookingSummary>>> getBookingsList() async {
    try {
      final result = await _apiClient.getBookings();
      if (result.isError()) {
        return Failure(
          result.exceptionOrNull() ??
              Exception('Unknown error fetching bookings'),
        );
      }
      final bookingsApi = result.getOrThrow();
      return Success(
        bookingsApi
            .map(
              (bookingApi) => BookingSummary(
                id: bookingApi.id!,
                name: bookingApi.name,
                startDate: bookingApi.startDate,
                endDate: bookingApi.endDate,
              ),
            )
            .toList(),
      );
    } on Exception catch (e) {
      return Failure(e);
    }
  }

  @override
  Future<Result<Unit>> delete(int id) async {
    try {
      return _apiClient.deleteBooking(id);
    } on Exception catch (e) {
      return Failure(e);
    }
  }
}
