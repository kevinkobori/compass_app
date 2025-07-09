import 'package:compass_app/config/dependencies.dart';
import 'package:compass_app/data/repositories/continent/continent_repository.dart';
import 'package:compass_app/data/repositories/itinerary_config/itinerary_config_repository.dart';
import 'package:compass_app/domain/models/continent/continent.dart';
import 'package:compass_app/domain/models/itinerary_config/itinerary_config.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:result_command/result_command.dart';
import 'package:result_dart/result_dart.dart';

/// Immutable state for [SearchFormViewModel].
@immutable
class SearchFormState {
  const SearchFormState({
    this.continents = const <Continent>[],
    this.selectedContinent,
    this.dateRange,
    this.guests = 0,
  });

  final List<Continent> continents;
  final String? selectedContinent;
  final DateTimeRange? dateRange;
  final int guests;

  bool get valid =>
      guests > 0 && selectedContinent != null && dateRange != null;

  SearchFormState copyWith({
    List<Continent>? continents,
    String? selectedContinent,
    DateTimeRange? dateRange,
    int? guests,
  }) {
    return SearchFormState(
      continents: continents ?? this.continents,
      selectedContinent: selectedContinent ?? this.selectedContinent,
      dateRange: dateRange ?? this.dateRange,
      guests: guests ?? this.guests,
    );
  }
}

class SearchFormViewModel extends Notifier<SearchFormState> {
  late ContinentRepository _continentRepository;
  late ItineraryConfigRepository _itineraryConfigRepository;

  @override
  SearchFormState build() {
    _continentRepository = ref.read(continentRepositoryProvider);
    _itineraryConfigRepository = ref.read(itineraryConfigRepositoryProvider);
    updateItineraryConfig = Command0(_updateItineraryConfig);
    load = Command0(_load)..execute();
    return const SearchFormState();
  }

  final _log = Logger('SearchFormViewModel');

  List<Continent> get continents => state.continents;

  String? get selectedContinent => state.selectedContinent;
  set selectedContinent(String? continent) {
    state = state.copyWith(selectedContinent: continent);
    _log.finest('Selected continent: $continent');
  }

  DateTimeRange? get dateRange => state.dateRange;
  set dateRange(DateTimeRange? dateRange) {
    state = state.copyWith(dateRange: dateRange);
    _log.finest('Selected date range: $dateRange');
  }

  int get guests => state.guests;
  set guests(int quantity) {
    final value = quantity < 0 ? 0 : quantity;
    state = state.copyWith(guests: value);
    _log.finest('Set guests number: $value');
  }

  bool get valid => state.valid;

  late final Command0 load;
  late final Command0 updateItineraryConfig;

  Future<Result<Unit>> _load() async {
    final result = await _loadContinents();
    if (result.isError()) {
      return Failure(
        result.exceptionOrNull() ?? Exception('Failed to load continents'),
      );
    }
    return _loadItineraryConfig();
  }

  Future<Result<Unit>> _loadContinents() async {
    final result = await _continentRepository.getContinents();
    if (result.isSuccess()) {
      final list = result.getOrThrow();
      state = state.copyWith(continents: list);
      _log.fine('Continents (${list.length}) loaded');
    } else {
      _log.warning('Failed to load continents', result.exceptionOrNull());
    }
    return result.map((_) => unit);
  }

  Future<Result<Unit>> _loadItineraryConfig() async {
    final result = await _itineraryConfigRepository.getItineraryConfig();
    if (result.isSuccess()) {
      final itineraryConfig = result.getOrThrow();
      state = state.copyWith(
        selectedContinent: itineraryConfig.continent,
        dateRange: itineraryConfig.startDate != null &&
                itineraryConfig.endDate != null
            ? DateTimeRange(
                start: itineraryConfig.startDate!,
                end: itineraryConfig.endDate!,
              )
            : null,
        guests: itineraryConfig.guests ?? 0,
      );
      _log.fine('ItineraryConfig loaded');
    } else {
      _log.warning(
        'Failed to load stored ItineraryConfig',
        result.exceptionOrNull(),
      );
    }
    return result.map((_) => unit);
  }

  Future<Result<Unit>> _updateItineraryConfig() async {
    assert(valid, 'called when valid was false');
    final result = await _itineraryConfigRepository.setItineraryConfig(
      ItineraryConfig(
        continent: state.selectedContinent,
        startDate: state.dateRange!.start,
        endDate: state.dateRange!.end,
        guests: state.guests,
      ),
    );
    if (result.isSuccess()) {
      _log.fine('ItineraryConfig saved');
    } else {
      _log.warning('Failed to store ItineraryConfig', result.exceptionOrNull());
    }
    return result.map((_) => unit);
  }
}

/// Provider exposing the [SearchFormViewModel] state and notifier.
final searchFormViewModelProvider =
    NotifierProvider<SearchFormViewModel, SearchFormState>(SearchFormViewModel.new);
