import 'dart:async';

import 'package:logging/logging.dart';
import 'package:result_dart/result_dart.dart';

/// Extension methods for handling [Result] types with automatic logging
/// and error propagation.
///
/// This extension provides convenient methods to handle success and failure
/// cases while maintaining type safety and reducing boilerplate code.
extension ResultHandling<S extends Object> on Result<S> {
  /// Handles the result asynchronously with automatic logging.
  ///
  /// This method encapsulates the pattern matching logic and logging,
  /// making it easier to chain operations while maintaining clean code.
  ///
  /// ⚠️ **IMPORTANT**: Always use `await` when calling this method inside
  /// a try/finally block to ensure proper execution order.
  ///
  /// **Type Parameters:**
  /// - `T`: The success type of the returned [Result]
  ///
  /// **Parameters:**
  /// - [logger]: The logger instance for recording operations
  /// - [successMessage]: Message to log on success
  /// - [failureMessage]: Message to log on failure
  /// - [onSuccess]: Callback executed with the success data
  /// - [successLevel]: Log level for success (default: [Level.FINE])
  /// - [failureLevel]: Log level for failure (default: [Level.WARNING])
  ///
  /// **Returns:**
  /// A [Future] containing the [Result] from [onSuccess] or a [Failure]
  /// with the original exception.
  ///
  /// **Example:**
  /// ```dart
  /// final result = await repository.getBookings();
  ///
  /// return await result.handle<User>(
  ///   logger: log,
  ///   successMessage: 'Bookings loaded successfully',
  ///   failureMessage: 'Failed to load bookings',
  ///   onSuccess: (bookings) async {
  ///     _bookings = bookings;
  ///     return await _loadUser();
  ///   },
  /// );
  /// ```
  Future<Result<T>> handle<T extends Object>({
    required Logger logger,
    required String successMessage,
    required String failureMessage,
    required Future<Result<T>> Function(S data) onSuccess,
    Level successLevel = Level.FINE,
    Level failureLevel = Level.WARNING,
  }) async {
    switch (this) {
      case Success<S, Exception>():
        final data = getOrThrow();
        logger.log(successLevel, successMessage);
        return await onSuccess(data);

      case Failure<S, Exception>():
        final error = exceptionOrNull();
        logger.log(failureLevel, failureMessage, error);
        return Failure(error ?? Exception(failureMessage));
    }
  }

  /// Handles the result synchronously with automatic logging.
  ///
  /// Use this method when your success handler returns a [Result]
  /// synchronously without async operations.
  ///
  /// **Type Parameters:**
  /// - `T`: The success type of the returned [Result]
  ///
  /// **Parameters:**
  /// - [logger]: The logger instance for recording operations
  /// - [successMessage]: Message to log on success
  /// - [failureMessage]: Message to log on failure
  /// - [onSuccess]: Synchronous callback executed with the success data
  /// - [successLevel]: Log level for success (default: [Level.FINE])
  /// - [failureLevel]: Log level for failure (default: [Level.WARNING])
  ///
  /// **Returns:**
  /// The [Result] from [onSuccess] or a [Failure] with the original exception.
  ///
  /// **Example:**
  /// ```dart
  /// return result.handleSync<String>(
  ///   logger: log,
  ///   successMessage: 'Data processed',
  ///   failureMessage: 'Processing failed',
  ///   onSuccess: (data) {
  ///     _cache = data;
  ///     return const Success('OK');
  ///   },
  /// );
  /// ```
  Result<T> handleSync<T extends Object>({
    required Logger logger,
    required String successMessage,
    required String failureMessage,
    required Result<T> Function(S data) onSuccess,
    Level successLevel = Level.FINE,
    Level failureLevel = Level.WARNING,
  }) {
    switch (this) {
      case Success<S, Exception>():
        final data = getOrThrow();
        logger.log(successLevel, successMessage);
        return onSuccess(data);

      case Failure<S, Exception>():
        final error = exceptionOrNull();
        logger.log(failureLevel, failureMessage, error);
        return Failure(error ?? Exception(failureMessage));
    }
  }

  /// Maps the success value to a new type without changing failure.
  ///
  /// This is a convenience method for transforming success values
  /// while preserving the error type.
  ///
  /// **Example:**
  /// ```dart
  /// final intResult = Success<int>(42);
  /// final stringResult = intResult.mapSuccess((value) => value.toString());
  /// // Result: Success<String>('42')
  /// ```
  Result<T> mapSuccess<T extends Object>(T Function(S value) mapper) {
    return switch (this) {
      Success<S, Exception>() => Success(mapper(getOrThrow())),
      Failure<S, Exception>() => Failure(exceptionOrNull()!),
    };
  }

  /// Executes a side effect on success without changing the result.
  ///
  /// Useful for logging, analytics, or other side effects that shouldn't
  /// alter the result flow.
  ///
  /// **Example:**
  /// ```dart
  /// return await repository.getData()
  ///   .tap((data) => print('Received: $data'))
  ///   .handle(...);
  /// ```
  Result<S> tap(void Function(S value) action) {
    if (this case Success<S, Exception>()) {
      action(getOrThrow());
    }
    return this;
  }

  /// Executes a side effect on failure without changing the result.
  ///
  /// Useful for error logging, metrics, or cleanup operations.
  ///
  /// **Example:**
  /// ```dart
  /// return await repository.getData()
  ///   .tapError((error) => analytics.logError(error))
  ///   .handle(...);
  /// ```
  Result<S> tapError(void Function(Exception error) action) {
    if (this case Failure<S, Exception>()) {
      final error = exceptionOrNull();
      if (error != null) action(error);
    }
    return this;
  }

  /// Recovers from a failure by providing a fallback value.
  ///
  /// **Example:**
  /// ```dart
  /// final result = await repository.getData()
  ///   .recover((error) => defaultData);
  /// // Always returns Success
  /// ```
  Result<S> recover(S Function(Exception error) fallback) {
    return switch (this) {
      Success<S, Exception>() => this,
      Failure<S, Exception>() => Success(fallback(exceptionOrNull()!)),
    };
  }

  /// Recovers from a failure by providing a fallback Result.
  ///
  /// **Example:**
  /// ```dart
  /// final result = await primaryRepo.getData()
  ///   .flatRecover((error) => secondaryRepo.getData());
  /// ```
  Result<S> flatRecover(Result<S> Function(Exception error) fallback) {
    return switch (this) {
      Success<S, Exception>() => this,
      Failure<S, Exception>() => fallback(exceptionOrNull()!),
    };
  }

  /// Transforms this Result into another Result type asynchronously.
  ///
  /// This is useful for chaining operations that return different Result types.
  ///
  /// **Example:**
  /// ```dart
  /// final userResult = await bookingsResult.flatMap((bookings) async {
  ///   return await userRepository.getUser();
  /// });
  /// ```
  Future<Result<T>> flatMap<T extends Object>(
    Future<Result<T>> Function(S value) mapper,
  ) async {
    return switch (this) {
      Success<S, Exception>() => await mapper(getOrThrow()),
      Failure<S, Exception>() => Failure(exceptionOrNull()!),
    };
  }

  /// Transforms this Result into another Result type synchronously.
  ///
  /// **Example:**
  /// ```dart
  /// final result = dataResult.flatMapSync((data) {
  ///   return validator.validate(data);
  /// });
  /// ```
  Result<T> flatMapSync<T extends Object>(Result<T> Function(S value) mapper) {
    return switch (this) {
      Success<S, Exception>() => mapper(getOrThrow()),
      Failure<S, Exception>() => Failure(exceptionOrNull()!),
    };
  }
}
