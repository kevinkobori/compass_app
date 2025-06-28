import 'dart:async';

import 'package:compass_app/data/repositories/booking/booking_repository.dart';
import 'package:compass_app/data/repositories/user/user_repository.dart';
import 'package:compass_app/domain/models/booking/booking_summary.dart';
import 'package:compass_app/domain/models/user/user.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:result_command/result_command.dart';
import 'package:result_dart/result_dart.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required BookingRepository bookingRepository,
    required UserRepository userRepository,
  }) : _bookingRepository = bookingRepository,
       _userRepository = userRepository {
    load = Command0(_load)..execute();
    deleteBooking = Command1(_deleteBooking);
  }

  final BookingRepository _bookingRepository;
  final UserRepository _userRepository;
  final _log = Logger('HomeViewModel');
  List<BookingSummary> _bookings = [];
  User? _user;

  late Command0 load;
  late Command1<void, int> deleteBooking;

  List<BookingSummary> get bookings => _bookings;
  User? get user => _user;

  Future<Result<User>> _load() async {
    try {
      // Carregar lista de bookings
      final result = await _bookingRepository.getBookingsList();
      if (result.isError()) {
        _log.warning('Failed to load bookings', result.exceptionOrNull());
        return Failure(
          result.exceptionOrNull() ?? Exception('Failed to load bookings'),
        );
      }
      _bookings = result.getOrThrow();
      _log.fine('Loaded bookings');

      // Carregar usuário
      final userResult = await _userRepository.getUser();
      if (userResult.isError()) {
        _log.warning('Failed to load user', userResult.exceptionOrNull());
        return Failure(
          userResult.exceptionOrNull() ?? Exception('Failed to load user'),
        );
      }
      _user = userResult.getOrThrow();
      _log.fine('Loaded user');

      return Success(_user!);
    } finally {
      notifyListeners();
    }
  }

  Future<Result<Unit>> _deleteBooking(int id) async {
    try {
      // Deletar booking
      final resultDelete = await _bookingRepository.delete(id);
      if (resultDelete.isError()) {
        _log.warning(
          'Failed to delete booking $id',
          resultDelete.exceptionOrNull(),
        );
        return Failure(
          resultDelete.exceptionOrNull() ??
              Exception('Failed to delete booking'),
        );
      }
      _log.fine('Deleted booking $id');

      // Atualizar lista de bookings
      final resultLoadBookings = await _bookingRepository.getBookingsList();
      if (resultLoadBookings.isError()) {
        _log.warning(
          'Failed to load bookings',
          resultLoadBookings.exceptionOrNull(),
        );
        return Failure(
          resultLoadBookings.exceptionOrNull() ??
              Exception('Failed to load bookings'),
        );
      }
      _bookings = resultLoadBookings.getOrThrow();
      _log.fine('Loaded bookings');

      return const Success(unit);
    } finally {
      notifyListeners();
    }
  }
}
