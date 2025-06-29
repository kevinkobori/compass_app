import 'package:compass_app/data/repositories/auth/auth_repository.dart';
import 'package:compass_app/data/repositories/itinerary_config/itinerary_config_repository.dart';
import 'package:compass_app/domain/models/itinerary_config/itinerary_config.dart';
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
  late Command0 logout;

  Future<Result<Unit>> _logout() async {
    final result = await _authLogoutRepository.logout();
    if (result.isError()) {
      return Failure(result.exceptionOrNull() ?? Exception('Logout failed'));
    }

    return _itineraryConfigRepository
        .setItineraryConfig(const ItineraryConfig())
        .then(
          (res) => res.map((_) => unit),
        );
  }
}
