import 'package:compass_app/data/repositories/booking/booking_repository.dart';
import 'package:compass_app/data/repositories/itinerary_config/itinerary_config_repository.dart';
import 'package:compass_app/domain/models/booking/booking.dart';
import 'package:compass_app/domain/use_cases/booking/booking_create_use_case.dart';
import 'package:compass_app/domain/use_cases/booking/booking_share_use_case.dart';
import 'package:compass_app/config/dependencies.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:result_command/result_command.dart';
import 'package:result_dart/result_dart.dart';

class BookingViewModel extends Notifier<Booking?> {
  late BookingCreateUseCase _createUseCase;
  late BookingShareUseCase _shareUseCase;
  late ItineraryConfigRepository _itineraryConfigRepository;
  late BookingRepository _bookingRepository;

  @override
  Booking? build() {
    _createUseCase = ref.read(bookingCreateUseCaseProvider);
    _shareUseCase = ref.read(bookingShareUseCaseProvider);
    _itineraryConfigRepository = ref.read(itineraryConfigRepositoryProvider);
    _bookingRepository = ref.read(bookingRepositoryProvider);
    createBooking = Command0(_createBooking);
    shareBooking = Command0(() => _shareUseCase.shareBooking(state!));
    loadBooking = Command1(_load);
    return null;
  }

  final _log = Logger('BookingViewModel');

  /// Current booking loaded or created.
  Booking? get booking => state;

  /// Creates a booking from the ItineraryConfig
  /// and saves it to the user bookings
  late final Command0 createBooking;

  /// Loads booking by id
  late final Command1<void, int> loadBooking;

  /// Share the current booking using the OS share dialog.
  late final Command0 shareBooking;

  Future<Result<Unit>> _createBooking() async {
    _log.fine('Loading booking');
    final itineraryResult =
        await _itineraryConfigRepository.getItineraryConfig();
    if (itineraryResult.isError()) {
      _log.warning(
        'ItineraryConfig error: ${itineraryResult.exceptionOrNull()}',
      );
      return Failure(
        itineraryResult.exceptionOrNull() ??
            Exception('Unknown ItineraryConfig error'),
      );
    }
    _log.fine('Loaded stored ItineraryConfig');

    final bookingResult = await _createUseCase.createFrom(
      itineraryResult.getOrThrow(),
    );
    if (bookingResult.isError()) {
      _log.warning('Booking error: ${bookingResult.exceptionOrNull()}');
      return Failure(
        bookingResult.exceptionOrNull() ?? Exception('Unknown Booking error'),
      );
    }
    _log.fine('Created Booking');
    state = bookingResult.getOrThrow();
    return const Success(unit);
  }

  Future<Result<Unit>> _load(int id) async {
    final result = await _bookingRepository.getBooking(id);
    if (result.isError()) {
      _log.warning('Failed to load booking $id: ${result.exceptionOrNull()}');
      return Failure(
        result.exceptionOrNull() ?? Exception('Failed to load booking'),
      );
    }
    _log.fine('Loaded booking $id');
    state = result.getOrThrow();
    return const Success(unit);
  }
}

/// Provider that exposes the [BookingViewModel] and its [Booking] state.
final bookingViewModelProvider =
    NotifierProvider<BookingViewModel, Booking?>(BookingViewModel.new);
