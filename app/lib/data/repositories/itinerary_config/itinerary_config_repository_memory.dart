import 'dart:async';

import '../../../domain/models/itinerary_config/itinerary_config.dart';
import 'package:result_dart/result_dart.dart';
import 'itinerary_config_repository.dart';

/// In-memory implementation of [ItineraryConfigRepository].
class ItineraryConfigRepositoryMemory implements ItineraryConfigRepository {
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
    return Success(unit);
  }
}
