import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:result_command/result_command.dart';

import '../../../data/repositories/booking/booking_repository.dart';
import '../../../data/repositories/itinerary_config/itinerary_config_repository.dart';
import '../../../domain/models/booking/booking.dart';
import '../../../domain/models/itinerary_config/itinerary_config.dart';
import '../../../domain/use_cases/booking/booking_create_use_case.dart';
import '../../../domain/use_cases/booking/booking_share_use_case.dart';

import 'package:result_dart/result_dart.dart';
import 'package:result_dart/functions.dart';

class BookingViewModel extends ChangeNotifier {
  BookingViewModel({
    required BookingCreateUseCase createBookingUseCase,
    required BookingShareUseCase shareBookingUseCase,
    required ItineraryConfigRepository itineraryConfigRepository,
    required BookingRepository bookingRepository,
  })  : _createUseCase = createBookingUseCase,
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
    _log.fine('Loading booking');
    final itineraryResult = await _itineraryConfigRepository.getItineraryConfig();
    if (itineraryResult.isError()) {
      _log.warning('ItineraryConfig error: ${itineraryResult.exceptionOrNull()}');
      notifyListeners();
      return Failure(itineraryResult.exceptionOrNull() ?? Exception('Unknown ItineraryConfig error'));
    }
    _log.fine('Loaded stored ItineraryConfig');

    final bookingResult = await _createUseCase.createFrom(itineraryResult.getOrThrow());
    if (bookingResult.isError()) {
      _log.warning('Booking error: ${bookingResult.exceptionOrNull()}');
      notifyListeners();
      return Failure(bookingResult.exceptionOrNull() ?? Exception('Unknown Booking error'));
    }
    _log.fine('Created Booking');
    _booking = bookingResult.getOrThrow();
    notifyListeners();
    return Success(unit);
  }

  Future<Result<Unit>> _load(int id) async {
    final result = await _bookingRepository.getBooking(id);
    if (result.isError()) {
      _log.warning('Failed to load booking $id: ${result.exceptionOrNull()}');
      return Failure(result.exceptionOrNull() ?? Exception('Failed to load booking'));
    }
    _log.fine('Loaded booking $id');
    _booking = result.getOrThrow();
    notifyListeners();
    return Success(unit);
  }
}
