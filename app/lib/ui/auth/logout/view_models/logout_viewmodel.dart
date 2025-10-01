import 'package:compass_app/data/repositories/auth/auth_repository.dart';
import 'package:compass_app/data/repositories/itinerary_config/itinerary_config_repository.dart';
import 'package:compass_app/domain/models/itinerary_config/itinerary_config.dart';
import 'package:compass_app/utils/result_extensions.dart';
import 'package:logging/logging.dart';
import 'package:result_command/result_command.dart';
import 'package:result_dart/result_dart.dart';

class LogoutViewModel {
  LogoutViewModel({
    required AuthRepository authRepository,
    required ItineraryConfigRepository itineraryConfigRepository,
  }) : _authLogoutRepository = authRepository,
       _itineraryConfigRepository = itineraryConfigRepository {
    logout = Command0(_logout);
  }

  final AuthRepository _authLogoutRepository;
  final ItineraryConfigRepository _itineraryConfigRepository;
  final _log = Logger('LogoutViewModel');
  late Command0 logout;

  Future<Result<Unit>> _logout() async {
    final logoutResult = await _authLogoutRepository.logout();

    return await logoutResult.handle<Unit>(
      logger: _log,
      successMessage: 'Logout successful',
      failureMessage: 'Logout failed',
      onSuccess: (_) async {
        final clearConfigResult = await _itineraryConfigRepository
            .setItineraryConfig(const ItineraryConfig());

        return clearConfigResult.handleSync<Unit>(
          logger: _log,
          successMessage: 'ItineraryConfig cleared',
          failureMessage: 'Failed to clear ItineraryConfig',
          onSuccess: (_) => const Success(unit),
        );
      },
    );
  }
}
