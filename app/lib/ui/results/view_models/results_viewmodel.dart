import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';
import 'package:result_command/result_command.dart';

import '../../../data/repositories/destination/destination_repository.dart';
import '../../../data/repositories/itinerary_config/itinerary_config_repository.dart';
import '../../../domain/models/destination/destination.dart';
import '../../../domain/models/itinerary_config/itinerary_config.dart';

import 'package:result_dart/result_dart.dart';
import 'package:result_dart/functions.dart';

class ResultsViewModel extends ChangeNotifier {
  ResultsViewModel({
    required DestinationRepository destinationRepository,
    required ItineraryConfigRepository itineraryConfigRepository,
  }) : _destinationRepository = destinationRepository,
       _itineraryConfigRepository = itineraryConfigRepository {
    updateItineraryConfig = Command1<Unit, String>(_updateItineraryConfig);
    search = Command0(_search)..execute();
  }

  final _log = Logger('ResultsViewModel');

  final DestinationRepository _destinationRepository;
  final ItineraryConfigRepository _itineraryConfigRepository;

  List<Destination> _destinations = [];
  List<Destination> get destinations => _destinations;

  ItineraryConfig? _itineraryConfig;
  ItineraryConfig get config => _itineraryConfig ?? const ItineraryConfig();

  late final Command0 search;
  late final Command1<void, String> updateItineraryConfig;

  Future<Result<Unit>> _search() async {
    // Load current itinerary config
    final resultConfig = await _itineraryConfigRepository.getItineraryConfig();
    if (resultConfig.isError()) {
      _log.warning(
        'Failed to load stored ItineraryConfig',
        resultConfig.exceptionOrNull(),
      );
      return Failure(
        resultConfig.exceptionOrNull() ??
            Exception('Unknown ItineraryConfig error'),
      );
    }
    _itineraryConfig = resultConfig.getOrThrow();
    notifyListeners();

    final result = await _destinationRepository.getDestinations();
    if (result.isSuccess()) {
      _destinations =
          result
              .getOrThrow()
              .where(
                (destination) =>
                    destination.continent == _itineraryConfig!.continent,
              )
              .toList();
      _log.fine('Destinations (${_destinations.length}) loaded');
    } else {
      _log.warning('Failed to load destinations', result.exceptionOrNull());
    }

    notifyListeners();
    return result.map((_) => unit); // sempre retorne Result<Unit>
  }

  Future<Result<Unit>> _updateItineraryConfig(String destinationRef) async {
    assert(destinationRef.isNotEmpty, "destinationRef should not be empty");

    final resultConfig = await _itineraryConfigRepository.getItineraryConfig();
    if (resultConfig.isError()) {
      _log.warning(
        'Failed to load stored ItineraryConfig',
        resultConfig.exceptionOrNull(),
      );
      return Failure(
        resultConfig.exceptionOrNull() ??
            Exception('Unknown ItineraryConfig error'),
      );
    }

    final itineraryConfig = resultConfig.getOrThrow();
    final result = await _itineraryConfigRepository.setItineraryConfig(
      itineraryConfig.copyWith(destination: destinationRef, activities: []),
    );
    if (result.isError()) {
      _log.warning('Failed to store ItineraryConfig', result.exceptionOrNull());
    }
    return result.map((_) => unit);
  }
}
