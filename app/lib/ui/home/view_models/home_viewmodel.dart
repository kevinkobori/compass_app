import 'dart:async';

import 'package:compass_app/data/repositories/booking/booking_repository.dart';
import 'package:compass_app/data/repositories/user/user_repository.dart';
import 'package:compass_app/domain/models/booking/booking_summary.dart';
import 'package:compass_app/domain/models/user/user.dart';
import 'package:compass_app/utils/base_viewmodel.dart';
import 'package:compass_app/utils/result_extensions.dart';
import 'package:result_command/result_command.dart';
import 'package:result_dart/result_dart.dart';

class HomeViewModel extends BaseViewModel {
  HomeViewModel({
    required BookingRepository bookingRepository,
    required UserRepository userRepository,
  }) : _bookingRepository = bookingRepository,
       _userRepository = userRepository,
       super('HomeViewModel') {
    _initializeCommands();
  }

  void _initializeCommands() {
    load = Command0(_load)..execute();
    deleteBooking = Command1(_deleteBooking);
  }

  final BookingRepository _bookingRepository;
  final UserRepository _userRepository;
  List<BookingSummary> _bookings = [];
  User? _user;

  late Command0 load;
  late Command1<void, int> deleteBooking;

  List<BookingSummary> get bookings => _bookings;
  User? get user => _user;

  Future<Result<User>> _load() => executeWithNotification(
    () async {
      final bookingsResult = await _bookingRepository.getBookingsList();

      return await bookingsResult.handle<User>(
        logger: logger,
        successMessage: 'Loaded bookings',
        failureMessage: 'Failed to load bookings',
        onSuccess: (bookings) async {
          _bookings = bookings;

          final userResult = await _userRepository.getUser();

          return await userResult.handle<User>(
            logger: logger,
            successMessage: 'Loaded user',
            failureMessage: 'Failed to load user',
            onSuccess: (user) async {
              _user = user;
              return Success(user);
            },
          );
        },
      );
    },
  );

  Future<Result<Unit>> _deleteBooking(int id) => executeWithNotification(
    () async {
      final deleteResult = await _bookingRepository.delete(id);

      return deleteResult.handle<Unit>(
        logger: logger,
        successMessage: 'Deleted booking $id',
        failureMessage: 'Failed to delete booking $id',
        onSuccess: (_) async {
          final reloadResult = await _bookingRepository.getBookingsList();

          return await reloadResult.handle<Unit>(
            logger: logger,
            successMessage: 'Reloaded bookings',
            failureMessage: 'Failed to reload bookings',
            onSuccess: (bookings) async {
              _bookings = bookings;
              return const Success(unit);
            },
          );
        },
      );
    },
  );
}
