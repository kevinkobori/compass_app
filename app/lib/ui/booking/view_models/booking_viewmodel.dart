import 'package:compass_app/data/repositories/booking/booking_repository.dart';
import 'package:compass_app/data/repositories/itinerary_config/itinerary_config_repository.dart';
import 'package:compass_app/domain/models/booking/booking.dart';
import 'package:compass_app/domain/use_cases/booking/booking_create_use_case.dart';
import 'package:compass_app/domain/use_cases/booking/booking_share_use_case.dart';
import 'package:compass_app/utils/result_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:result_command/result_command.dart';
import 'package:result_dart/result_dart.dart';

class BookingViewModel extends ChangeNotifier {
  BookingViewModel({
    required BookingCreateUseCase createBookingUseCase,
    required BookingShareUseCase shareBookingUseCase,
    required ItineraryConfigRepository itineraryConfigRepository,
    required BookingRepository bookingRepository,
  }) : _createUseCase = createBookingUseCase,
       _shareUseCase = shareBookingUseCase,
       _itineraryConfigRepository = itineraryConfigRepository,
       _bookingRepository = bookingRepository {
    createBooking = Command0(_createBooking);
    shareBooking = Command0(() => _shareUseCase.shareBooking(_booking!));
    loadBooking = Command1(_load);
  }

  final BookingCreateUseCase _createUseCase;
  final BookingShareUseCase _shareUseCase;
  final ItineraryConfigRepository _itineraryConfigRepository;
  final BookingRepository _bookingRepository;
  final _log = Logger('BookingViewModel');
  Booking? _booking;

  Booking? get booking => _booking;

  /// Creates a booking from the ItineraryConfig
  /// and saves it to the user bookings
  late final Command0 createBooking;

  /// Loads booking by id
  late final Command1<void, int> loadBooking;

  /// Share the current booking using the OS share dialog.
  late final Command0 shareBooking;

  Future<Result<Unit>> _createBooking() async {
    final itineraryResult = await _itineraryConfigRepository
        .getItineraryConfig();

    return await itineraryResult.handle<Unit>(
      logger: _log,
      successMessage: 'Loaded stored ItineraryConfig',
      failureMessage: 'ItineraryConfig error',
      onSuccess: (itineraryConfig) async {
        final bookingResult = await _createUseCase.createFrom(itineraryConfig);

        return await bookingResult.handle<Unit>(
          logger: _log,
          successMessage: 'Created Booking',
          failureMessage: 'Booking error',
          onSuccess: (booking) async {
            _booking = booking;
            notifyListeners();
            return const Success(unit);
          },
        );
      },
    );
  }

  Future<Result<Unit>> _load(int id) async {
    final result = await _bookingRepository.getBooking(id);

    return await result.handle<Unit>(
      logger: _log,
      successMessage: 'Loaded booking $id',
      failureMessage: 'Failed to load booking $id',
      onSuccess: (booking) async {
        _booking = booking;
        notifyListeners();
        return const Success(unit);
      },
    );
  }
}
