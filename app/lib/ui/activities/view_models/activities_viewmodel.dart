import 'package:compass_app/data/repositories/activity/activity_repository.dart';
import 'package:compass_app/data/repositories/itinerary_config/itinerary_config_repository.dart';
import 'package:compass_app/domain/models/activity/activity.dart';
import 'package:compass_app/domain/models/destination/destination.dart'
    show Destination;
import 'package:compass_app/utils/result_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:result_command/result_command.dart';
import 'package:result_dart/result_dart.dart';

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
    final configResult = await _itineraryConfigRepository.getItineraryConfig();

    return await configResult.handle<Unit>(
      logger: _log,
      successMessage: 'ItineraryConfig loaded',
      failureMessage: 'Failed to load stored ItineraryConfig',
      onSuccess: (itineraryConfig) async {
        final destinationRef = itineraryConfig.destination;
        if (destinationRef == null) {
          _log.severe('Destination missing in ItineraryConfig');
          return Failure(Exception('Destination not found'));
        }

        _selectedActivities.addAll(itineraryConfig.activities);

        final activitiesResult = await _activityRepository.getByDestination(
          destinationRef,
        );

        return await activitiesResult.handle<Unit>(
          logger: _log,
          successMessage:
              'Activities (${activitiesResult.getOrNull()?.length ?? 0}) loaded',
          failureMessage: 'Failed to load activities',
          onSuccess: (activities) async {
            _daytimeActivities = activities
                .where(
                  (activity) => [
                    TimeOfDay.any,
                    TimeOfDay.morning,
                    TimeOfDay.afternoon,
                  ].contains(activity.timeOfDay),
                )
                .toList();

            _eveningActivities = activities
                .where(
                  (activity) => [
                    TimeOfDay.evening,
                    TimeOfDay.night,
                  ].contains(activity.timeOfDay),
                )
                .toList();

            notifyListeners();
            return const Success(unit);
          },
        );
      },
    );
  }

  /// Add [Activity] to selected list.
  void addActivity(String activityRef) {
    assert(
      (_daytimeActivities + _eveningActivities).any(
        (activity) => activity.ref == activityRef,
      ),
      'Activity $activityRef not found',
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
      'Activity $activityRef not found',
    );
    _selectedActivities.remove(activityRef);
    _log.finest('Activity $activityRef removed');
    notifyListeners();
  }

  Future<Result<Unit>> _saveActivities() async {
    final configResult = await _itineraryConfigRepository.getItineraryConfig();

    return await configResult.handle<Unit>(
      logger: _log,
      successMessage: 'ItineraryConfig loaded for save',
      failureMessage: 'Failed to load stored ItineraryConfig',
      onSuccess: (itineraryConfig) async {
        final saveResult = await _itineraryConfigRepository.setItineraryConfig(
          itineraryConfig.copyWith(activities: _selectedActivities.toList()),
        );

        return saveResult.handleSync<Unit>(
          logger: _log,
          successMessage: 'Activities saved to ItineraryConfig',
          failureMessage: 'Failed to store ItineraryConfig',
          onSuccess: (_) => const Success(unit),
        );
      },
    );
  }
}
