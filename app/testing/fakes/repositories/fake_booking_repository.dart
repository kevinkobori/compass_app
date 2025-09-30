// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:compass_app/data/repositories/booking/booking_repository.dart';
import 'package:compass_app/domain/models/booking/booking.dart';
import 'package:compass_app/domain/models/booking/booking_summary.dart';
import 'package:result_dart/result_dart.dart';

class FakeBookingRepository implements BookingRepository {
  List<Booking> bookings = List.empty(growable: true);
  int sequentialId = 0;

  @override
  Future<Result<Unit>> createBooking(Booking booking) async {
    final bookingWithId = booking.copyWith(id: sequentialId++);
    bookings.add(bookingWithId);
    return const Success(unit);
  }

  @override
  Future<Result<Booking>> getBooking(int id) async {
    return Success(bookings[id]);
  }

  @override
  Future<Result<List<BookingSummary>>> getBookingsList() async {
    return Success(_createSummaries());
  }

  List<BookingSummary> _createSummaries() {
    return bookings
        .map(
          (booking) => BookingSummary(
            id: booking.id!,
            name:
                '${booking.destination.name}, ${booking.destination.continent}',
            startDate: booking.startDate,
            endDate: booking.endDate,
          ),
        )
        .toList();
  }

  @override
  Future<Result<Unit>> delete(int id) async {
    bookings.removeWhere((booking) => booking.id == id);
    return const Success(unit);
  }
}
