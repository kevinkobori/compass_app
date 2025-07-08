import 'package:compass_app/data/repositories/activity/activity_repository.dart';
import 'package:compass_app/data/repositories/itinerary_config/itinerary_config_repository.dart';
import 'package:compass_app/domain/models/activity/activity.dart';
import 'package:compass_app/domain/models/destination/destination.dart'
    show Destination;
import 'package:compass_app/config/dependencies.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:result_command/result_command.dart';
import 'package:result_dart/result_dart.dart';

/// Immutable state for [ActivitiesViewModel].
@immutable
class ActivitiesState {
  const ActivitiesState({
    this.daytimeActivities = const <Activity>[],
    this.eveningActivities = const <Activity>[],
    this.selectedActivities = const <String>{},
  });

  final List<Activity> daytimeActivities;
  final List<Activity> eveningActivities;
  final Set<String> selectedActivities;

  ActivitiesState copyWith({
    List<Activity>? daytimeActivities,
    List<Activity>? eveningActivities,
    Set<String>? selectedActivities,
  }) {
    return ActivitiesState(
      daytimeActivities: daytimeActivities ?? this.daytimeActivities,
      eveningActivities: eveningActivities ?? this.eveningActivities,
      selectedActivities: selectedActivities ?? this.selectedActivities,
    );
  }
}

/// View model backed by Riverpod [Notifier].
class ActivitiesViewModel extends Notifier<ActivitiesState> {
  late ActivityRepository _activityRepository;
  late ItineraryConfigRepository _itineraryConfigRepository;

  @override
  ActivitiesState build() {
    _activityRepository = ref.read(activityRepositoryProvider);
    _itineraryConfigRepository = ref.read(itineraryConfigRepositoryProvider);
    loadActivities = Command0(_loadActivities)..execute();
    saveActivities = Command0(_saveActivities);
    return const ActivitiesState();
  }

  final _log = Logger('ActivitiesViewModel');

  /// Current activities state.
  List<Activity> get daytimeActivities => state.daytimeActivities;
  List<Activity> get eveningActivities => state.eveningActivities;
  Set<String> get selectedActivities => state.selectedActivities;

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

    final selected = <String>{...itineraryConfig.activities};

    final resultActivities = await _activityRepository.getByDestination(
      destinationRef,
    );
    if (resultActivities.isSuccess()) {
      final activities = resultActivities.getOrThrow();
      final daytime =
          activities
              .where(
                (activity) => [
                  TimeOfDay.any,
                  TimeOfDay.morning,
                  TimeOfDay.afternoon,
                ].contains(activity.timeOfDay),
              )
              .toList();

      final evening =
          activities
              .where(
                (activity) => [
                  TimeOfDay.evening,
                  TimeOfDay.night,
                ].contains(activity.timeOfDay),
              )
              .toList();

      _log.fine(
        'Activities (daytime: ${daytime.length}, evening: ${evening.length}) loaded',
      );
      state = state.copyWith(
        daytimeActivities: daytime,
        eveningActivities: evening,
        selectedActivities: selected,
      );
    } else {
      _log.warning(
        'Failed to load activities',
        resultActivities.exceptionOrNull(),
      );
    }

    state = state.copyWith(selectedActivities: selected);
    return resultActivities.map((_) => unit);
  }

  /// Add [Activity] to selected list.
  void addActivity(String activityRef) {
    assert(
      (daytimeActivities + eveningActivities).any(
        (activity) => activity.ref == activityRef,
      ),
      'Activity $activityRef not found',
    );
    final updated = <String>{...selectedActivities}..add(activityRef);
    state = state.copyWith(selectedActivities: updated);
    _log.finest('Activity $activityRef added');
  }

  /// Remove [Activity] from selected list.
  void removeActivity(String activityRef) {
    assert(
      (daytimeActivities + eveningActivities).any(
        (activity) => activity.ref == activityRef,
      ),
      'Activity $activityRef not found',
    );
    final updated = <String>{...selectedActivities}..remove(activityRef);
    state = state.copyWith(selectedActivities: updated);
    _log.finest('Activity $activityRef removed');
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
      itineraryConfig.copyWith(activities: selectedActivities.toList()),
    );
    if (result.isError()) {
      _log.warning('Failed to store ItineraryConfig', result.exceptionOrNull());
    }

    return result.map((_) => unit);
  }
}

/// Provider exposing the [ActivitiesViewModel] state and notifier.
final activitiesViewModelProvider =
    NotifierProvider<ActivitiesViewModel, ActivitiesState>(
  ActivitiesViewModel.new,
);
