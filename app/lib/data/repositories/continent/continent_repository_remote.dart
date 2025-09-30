import 'package:compass_app/data/repositories/continent/continent_repository.dart';
import 'package:compass_app/data/services/api/api_client.dart';
import 'package:compass_app/domain/models/continent/continent.dart';
import 'package:result_dart/result_dart.dart';

/// Remote data source for [Continent].
/// Implements basic local caching.
/// See: https://docs.flutter.dev/get-started/fwe/local-caching
class ContinentRepositoryRemote implements ContinentRepository {
  ContinentRepositoryRemote({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  List<Continent>? _cachedData;

  @override
  Future<Result<List<Continent>>> getContinents() async {
    if (_cachedData == null) {
      // No cached data, request continents
      final result = await _apiClient.getContinents();
      if (result.isSuccess()) {
        // Store value if result Success
        _cachedData = result.getOrThrow();
      }
      return result;
    } else {
      // Return cached data if available
      return Success(_cachedData!);
    }
  }
}
