import 'dart:async';

import 'package:compass_app/data/repositories/itinerary_config/itinerary_config_repository.dart';
import 'package:compass_app/domain/models/itinerary_config/itinerary_config.dart';
import 'package:result_dart/result_dart.dart';

/// In-memory implementation of [ItineraryConfigRepository].
class MemoryItineraryConfigRepository implements ItineraryConfigRepository {
  ItineraryConfig? _itineraryConfig;

  @override
  Future<Result<ItineraryConfig>> getItineraryConfig() async {
    return Success(_itineraryConfig ?? const ItineraryConfig());
  }

  @override
  Future<Result<Unit>> setItineraryConfig(
    ItineraryConfig itineraryConfig,
  ) async {
    _itineraryConfig = itineraryConfig;
    return const Success(unit);
  }
}
