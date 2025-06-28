import 'package:compass_app/data/repositories/user/user_repository.dart';
import 'package:compass_app/data/services/api/api_client.dart';
import 'package:compass_app/domain/models/user/user.dart';
import 'package:result_dart/result_dart.dart';

class UserRepositoryRemote implements UserRepository {
  UserRepositoryRemote({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  User? _cachedData;

  @override
  Future<Result<User>> getUser() async {
    if (_cachedData != null) {
      return Success(_cachedData!);
    }

    final result = await _apiClient.getUser();
    if (result.isError()) {
      return Failure(
        result.exceptionOrNull() ?? Exception('Unknown user error'),
      );
    }

    final userApiModel = result.getOrThrow();
    final user = User(name: userApiModel.name, picture: userApiModel.picture);
    _cachedData = user;
    return Success(user);
  }
}
