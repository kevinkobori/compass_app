import '../../../domain/models/destination/destination.dart';
import 'package:result_dart/result_dart.dart';
import '../../services/api/api_client.dart';
import 'destination_repository.dart';

/// Remote data source for [Destination].
/// Implements basic local caching.
/// See: https://docs.flutter.dev/get-started/fwe/local-caching
class DestinationRepositoryRemote implements DestinationRepository {
  DestinationRepositoryRemote({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  List<Destination>? _cachedData;

  @override
  Future<Result<List<Destination>>> getDestinations() async {
    if (_cachedData == null) {
      // No cached data, request destinations
      final result = await _apiClient.getDestinations();
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
