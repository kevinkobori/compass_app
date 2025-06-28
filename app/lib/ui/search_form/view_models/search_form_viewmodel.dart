import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:result_command/result_command.dart';

import '../../../data/repositories/continent/continent_repository.dart';
import '../../../data/repositories/itinerary_config/itinerary_config_repository.dart';
import '../../../domain/models/continent/continent.dart';
import '../../../domain/models/itinerary_config/itinerary_config.dart';

import 'package:result_dart/result_dart.dart';
import 'package:result_dart/functions.dart';

class SearchFormViewModel extends ChangeNotifier {
  SearchFormViewModel({
    required ContinentRepository continentRepository,
    required ItineraryConfigRepository itineraryConfigRepository,
  })  : _continentRepository = continentRepository,
        _itineraryConfigRepository = itineraryConfigRepository {
    updateItineraryConfig = Command0(_updateItineraryConfig);
    load = Command0(_load)..execute();
  }

  final _log = Logger('SearchFormViewModel');
  final ContinentRepository _continentRepository;
  final ItineraryConfigRepository _itineraryConfigRepository;
  List<Continent> _continents = [];
  String? _selectedContinent;
  DateTimeRange? _dateRange;
  int _guests = 0;

  bool get valid =>
      _guests > 0 && _selectedContinent != null && _dateRange != null;

  List<Continent> get continents => _continents;

  String? get selectedContinent => _selectedContinent;
  set selectedContinent(String? continent) {
    _selectedContinent = continent;
    _log.finest('Selected continent: $continent');
    notifyListeners();
  }

  DateTimeRange? get dateRange => _dateRange;
  set dateRange(DateTimeRange? dateRange) {
    _dateRange = dateRange;
    _log.finest('Selected date range: $dateRange');
    notifyListeners();
  }

  int get guests => _guests;
  set guests(int quantity) {
    _guests = quantity < 0 ? 0 : quantity;
    _log.finest('Set guests number: $_guests');
    notifyListeners();
  }

  late final Command0 load;
  late final Command0 updateItineraryConfig;

  Future<Result<Unit>> _load() async {
    final result = await _loadContinents();
    if (result.isError()) {
      return Failure(result.exceptionOrNull() ?? Exception('Failed to load continents'));
    }
    return await _loadItineraryConfig();
  }

  Future<Result<Unit>> _loadContinents() async {
    final result = await _continentRepository.getContinents();
    if (result.isSuccess()) {
      _continents = result.getOrThrow();
      _log.fine('Continents (${_continents.length}) loaded');
    } else {
      _log.warning('Failed to load continents', result.exceptionOrNull());
    }
    notifyListeners();
    return result.map((_) => unit);
  }

  Future<Result<Unit>> _loadItineraryConfig() async {
    final result = await _itineraryConfigRepository.getItineraryConfig();
    if (result.isSuccess()) {
      final itineraryConfig = result.getOrThrow();
      _selectedContinent = itineraryConfig.continent;
      if (itineraryConfig.startDate != null && itineraryConfig.endDate != null) {
        _dateRange = DateTimeRange(
          start: itineraryConfig.startDate!,
          end: itineraryConfig.endDate!,
        );
      }
      _guests = itineraryConfig.guests ?? 0;
      _log.fine('ItineraryConfig loaded');
      notifyListeners();
    } else {
      _log.warning('Failed to load stored ItineraryConfig', result.exceptionOrNull());
    }
    return result.map((_) => unit);
  }

  Future<Result<Unit>> _updateItineraryConfig() async {
    assert(valid, "called when valid was false");
    final result = await _itineraryConfigRepository.setItineraryConfig(
      ItineraryConfig(
        continent: _selectedContinent,
        startDate: _dateRange!.start,
        endDate: _dateRange!.end,
        guests: _guests,
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
