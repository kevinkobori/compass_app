import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:result_dart/result_dart.dart';

abstract class BaseViewModel extends ChangeNotifier {
  BaseViewModel(String loggerName) {
    logger = Logger(loggerName);
  }

  @protected
  late final Logger logger;

  /// Safely executes an operation and notifies listeners
  @protected
  Future<Result<T>> executeWithNotification<T extends Object>(
    Future<Result<T>> Function() operation,
  ) async {
    try {
      return await operation();
    } finally {
      // notifyListeners();
    }
  }
}
