import 'package:compass_app/data/repositories/destination/destination_repository.dart';
import 'package:compass_app/data/repositories/itinerary_config/itinerary_config_repository.dart';
import 'package:compass_app/domain/models/destination/destination.dart';
import 'package:compass_app/domain/models/itinerary_config/itinerary_config.dart';
import 'package:compass_app/config/dependencies.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:result_command/result_command.dart';
import 'package:result_dart/result_dart.dart';

/// State for [ResultsViewModel].
@immutable
class ResultsState {
  const ResultsState({
    this.destinations = const <Destination>[],
    this.config = const ItineraryConfig(),
  });

  final List<Destination> destinations;
  final ItineraryConfig config;

  ResultsState copyWith({
    List<Destination>? destinations,
    ItineraryConfig? config,
  }) {
    return ResultsState(
      destinations: destinations ?? this.destinations,
      config: config ?? this.config,
    );
  }
}

/// View model backed by Riverpod [Notifier].
class ResultsViewModel extends Notifier<ResultsState> {
  late DestinationRepository _destinationRepository;
  late ItineraryConfigRepository _itineraryConfigRepository;

  @override
  ResultsState build() {
    _destinationRepository = ref.read(destinationRepositoryProvider);
    _itineraryConfigRepository = ref.read(itineraryConfigRepositoryProvider);
    updateItineraryConfig = Command1<Unit, String>(_updateItineraryConfig);
    search = Command0(_search)..execute();
    return const ResultsState();
  }

  final _log = Logger('ResultsViewModel');

  /// Current state values.
  List<Destination> get destinations => state.destinations;
  ItineraryConfig get config => state.config;

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
    final itineraryConfig = resultConfig.getOrThrow();
    state = state.copyWith(config: itineraryConfig);

    final result = await _destinationRepository.getDestinations();
    if (result.isSuccess()) {
      final list = result
          .getOrThrow()
          .where(
            (destination) => destination.continent == itineraryConfig.continent,
          )
          .toList();
      state = state.copyWith(destinations: list);
      _log.fine('Destinations (${list.length}) loaded');
    } else {
      _log.warning('Failed to load destinations', result.exceptionOrNull());
    }

    return result.map((_) => unit); // sempre retorne Result<Unit>
  }

  Future<Result<Unit>> _updateItineraryConfig(String destinationRef) async {
    assert(destinationRef.isNotEmpty, 'destinationRef should not be empty');

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

/// Provider exposing the [ResultsViewModel].
final resultsViewModelProvider =
    NotifierProvider<ResultsViewModel, ResultsState>(ResultsViewModel.new);
