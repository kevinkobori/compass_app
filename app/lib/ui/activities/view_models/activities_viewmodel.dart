import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../data/repositories/activity/activity_repository.dart';
import '../../../data/repositories/itinerary_config/itinerary_config_repository.dart';
import '../../../domain/models/activity/activity.dart';
import '../../../domain/models/itinerary_config/itinerary_config.dart';

import 'package:result_dart/result_dart.dart';
import 'package:result_command/result_command.dart';

class ActivitiesViewModel extends ChangeNotifier {
  ActivitiesViewModel({
    required ActivityRepository activityRepository,
    required ItineraryConfigRepository itineraryConfigRepository,
  }) : _activityRepository = activityRepository,
       _itineraryConfigRepository = itineraryConfigRepository {
    loadActivities = Command0(_loadActivities)..execute();
    saveActivities = Command0(_saveActivities);
  }

  final _log = Logger('ActivitiesViewModel');
  final ActivityRepository _activityRepository;
  final ItineraryConfigRepository _itineraryConfigRepository;
  List<Activity> _daytimeActivities = <Activity>[];
  List<Activity> _eveningActivities = <Activity>[];
  final Set<String> _selectedActivities = <String>{};

  /// List of daytime [Activity] per destination.
  List<Activity> get daytimeActivities => _daytimeActivities;

  /// List of evening [Activity] per destination.
  List<Activity> get eveningActivities => _eveningActivities;

  /// Selected [Activity] by ref.
  Set<String> get selectedActivities => _selectedActivities;

  /// Load list of [Activity] for a [Destination] by ref.
  late final Command0 loadActivities;

  /// Save list [selectedActivities] into itinerary configuration.
  late final Command0 saveActivities;

  Future<Result<Unit>> _loadActivities() async {
    final result = await _itineraryConfigRepository.getItineraryConfig();
    if (result.isError()) {
      _log.warning(
        'Failed to load stored ItineraryConfig',
        result.exceptionOrNull(),
      );
      return Failure(
        result.exceptionOrNull() ?? Exception('Unknown ItineraryConfig error'),
      );
    }

    final itineraryConfig = result.getOrThrow();
    final destinationRef = itineraryConfig.destination;
    if (destinationRef == null) {
      _log.severe('Destination missing in ItineraryConfig');
      return Failure(Exception('Destination not found'));
    }

    _selectedActivities.addAll(itineraryConfig.activities);

    final resultActivities = await _activityRepository.getByDestination(
      destinationRef,
    );
    if (resultActivities.isSuccess()) {
      final activities = resultActivities.getOrThrow();
      _daytimeActivities =
          activities
              .where(
                (activity) => [
                  TimeOfDay.any,
                  TimeOfDay.morning,
                  TimeOfDay.afternoon,
                ].contains(activity.timeOfDay),
              )
              .toList();

      _eveningActivities =
          activities
              .where(
                (activity) => [
                  TimeOfDay.evening,
                  TimeOfDay.night,
                ].contains(activity.timeOfDay),
              )
              .toList();

      _log.fine(
        'Activities (daytime: ${_daytimeActivities.length}, '
        'evening: ${_eveningActivities.length}) loaded',
      );
    } else {
      _log.warning(
        'Failed to load activities',
        resultActivities.exceptionOrNull(),
      );
    }

    notifyListeners();
    return resultActivities.map((_) => unit);
  }

  /// Add [Activity] to selected list.
  void addActivity(String activityRef) {
    assert(
      (_daytimeActivities + _eveningActivities).any(
        (activity) => activity.ref == activityRef,
      ),
      "Activity $activityRef not found",
    );
    _selectedActivities.add(activityRef);
    _log.finest('Activity $activityRef added');
    notifyListeners();
  }

  /// Remove [Activity] from selected list.
  void removeActivity(String activityRef) {
    assert(
      (_daytimeActivities + _eveningActivities).any(
        (activity) => activity.ref == activityRef,
      ),
      "Activity $activityRef not found",
    );
    _selectedActivities.remove(activityRef);
    _log.finest('Activity $activityRef removed');
    notifyListeners();
  }

  Future<Result<Unit>> _saveActivities() async {
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
      itineraryConfig.copyWith(activities: _selectedActivities.toList()),
    );
    if (result.isError()) {
      _log.warning('Failed to store ItineraryConfig', result.exceptionOrNull());
    }

    return result.map((_) => unit);
  }
}
