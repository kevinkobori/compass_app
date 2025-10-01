import 'package:compass_app/data/repositories/continent/continent_repository.dart';
import 'package:compass_app/data/repositories/itinerary_config/itinerary_config_repository.dart';
import 'package:compass_app/domain/models/continent/continent.dart';
import 'package:compass_app/domain/models/itinerary_config/itinerary_config.dart';
import 'package:compass_app/utils/result_extensions.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:result_command/result_command.dart';
import 'package:result_dart/result_dart.dart';

class SearchFormViewModel extends ChangeNotifier {
  SearchFormViewModel({
    required ContinentRepository continentRepository,
    required ItineraryConfigRepository itineraryConfigRepository,
  }) : _continentRepository = continentRepository,
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
    final result = await _continentRepository.getContinents();

    return await result.handle<Unit>(
      logger: _log,
      successMessage: 'Continents (${result.getOrNull()?.length ?? 0}) loaded',
      failureMessage: 'Failed to load continents',
      onSuccess: (continents) async {
        _continents = continents;
        notifyListeners();
        return await _loadItineraryConfig();
      },
    );
  }

  Future<Result<Unit>> _loadItineraryConfig() async {
    final result = await _itineraryConfigRepository.getItineraryConfig();

    return result.handleSync<Unit>(
      logger: _log,
      successMessage: 'ItineraryConfig loaded',
      failureMessage: 'Failed to load stored ItineraryConfig',
      onSuccess: (itineraryConfig) {
        _selectedContinent = itineraryConfig.continent;
        if (itineraryConfig.startDate != null &&
            itineraryConfig.endDate != null) {
          _dateRange = DateTimeRange(
            start: itineraryConfig.startDate!,
            end: itineraryConfig.endDate!,
          );
        }
        _guests = itineraryConfig.guests ?? 0;
        notifyListeners();
        return const Success(unit);
      },
    );
  }

  Future<Result<Unit>> _updateItineraryConfig() async {
    assert(valid, 'called when valid was false');
    final result = await _itineraryConfigRepository.setItineraryConfig(
      ItineraryConfig(
        continent: _selectedContinent,
        startDate: _dateRange!.start,
        endDate: _dateRange!.end,
        guests: _guests,
      ),
    );

    return result.handleSync<Unit>(
      logger: _log,
      successMessage: 'ItineraryConfig saved',
      failureMessage: 'Failed to store ItineraryConfig',
      onSuccess: (_) => const Success(unit),
    );
  }
}
