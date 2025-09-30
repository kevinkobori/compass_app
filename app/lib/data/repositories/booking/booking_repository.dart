// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:compass_app/domain/models/booking/booking.dart';
import 'package:compass_app/domain/models/booking/booking_summary.dart';
import 'package:result_dart/result_dart.dart';

abstract class BookingRepository {
  /// Returns the list of [BookingSummary] for the current user.
  Future<Result<List<BookingSummary>>> getBookingsList();

  /// Returns a full [Booking] given the id.
  Future<Result<Booking>> getBooking(int id);

  /// Creates a new [Booking].
  Future<Result<Unit>> createBooking(Booking booking);

  /// Delete booking
  Future<Result<Unit>> delete(int id);
}
