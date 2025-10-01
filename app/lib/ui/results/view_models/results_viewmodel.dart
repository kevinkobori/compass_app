import 'package:compass_app/data/repositories/destination/destination_repository.dart';
import 'package:compass_app/data/repositories/itinerary_config/itinerary_config_repository.dart';
import 'package:compass_app/domain/models/destination/destination.dart';
import 'package:compass_app/domain/models/itinerary_config/itinerary_config.dart';
import 'package:compass_app/utils/result_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';
import 'package:result_command/result_command.dart';
import 'package:result_dart/result_dart.dart';

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
    final configResult = await _itineraryConfigRepository.getItineraryConfig();

    return await configResult.handle<Unit>(
      logger: _log,
      successMessage: 'ItineraryConfig loaded',
      failureMessage: 'Failed to load stored ItineraryConfig',
      onSuccess: (itineraryConfig) async {
        _itineraryConfig = itineraryConfig;
        notifyListeners();

        final destinationsResult = await _destinationRepository
            .getDestinations();

        return await destinationsResult.handle<Unit>(
          logger: _log,
          successMessage:
              'Destinations (${destinationsResult.getOrNull()?.length ?? 0}) loaded',
          failureMessage: 'Failed to load destinations',
          onSuccess: (allDestinations) async {
            _destinations = allDestinations
                .where(
                  (destination) =>
                      destination.continent == _itineraryConfig!.continent,
                )
                .toList();
            notifyListeners();
            return const Success(unit);
          },
        );
      },
    );
  }

  Future<Result<Unit>> _updateItineraryConfig(String destinationRef) async {
    assert(destinationRef.isNotEmpty, 'destinationRef should not be empty');

    final configResult = await _itineraryConfigRepository.getItineraryConfig();

    return await configResult.handle<Unit>(
      logger: _log,
      successMessage: 'ItineraryConfig loaded for update',
      failureMessage: 'Failed to load stored ItineraryConfig',
      onSuccess: (itineraryConfig) async {
        final saveResult = await _itineraryConfigRepository.setItineraryConfig(
          itineraryConfig.copyWith(
            destination: destinationRef,
            activities: [],
          ),
        );

        return saveResult.handleSync<Unit>(
          logger: _log,
          successMessage: 'ItineraryConfig updated with destination',
          failureMessage: 'Failed to store ItineraryConfig',
          onSuccess: (_) => const Success(unit),
        );
      },
    );
  }
}
