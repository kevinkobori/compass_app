import 'package:result_dart/result_dart.dart';

extension ResultCast<T> on Result<T> {
  /// Convenience method to cast to [Success].
  Success<T> get asSuccess => this as Success<T>;

  /// Convenience method to cast to [Failure].
  Failure get asFailure => this as Failure;
}
