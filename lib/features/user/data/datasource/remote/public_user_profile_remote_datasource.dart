import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pairup/core/api/api_client.dart';
import 'package:pairup/features/user/data/models/public_user_profile_api_model.dart';

abstract interface class IPublicUserProfileRemoteDatasource {
  Future<PublicUserProfileApiModel> getPublicUserProfile(
    String userId, {
    bool trackView = true,
  });
}

final publicUserProfileRemoteDatasourceProvider =
    Provider<IPublicUserProfileRemoteDatasource>((ref) {
      return PublicUserProfileRemoteDatasource(
        apiClient: ref.read(apiClientProvider),
      );
    });

class PublicUserProfileRemoteDatasource
    implements IPublicUserProfileRemoteDatasource {
  final ApiClient _apiClient;

  PublicUserProfileRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<PublicUserProfileApiModel> getPublicUserProfile(
    String userId, {
    bool trackView = true,
  }) async {
    final normalized = userId.trim();
    if (normalized.isEmpty) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/users/profile/$userId'),
        error: 'User id is required',
      );
    }

    final response = await _apiClient.get(
      '/api/users/profile/${Uri.encodeComponent(normalized)}',
      queryParameters: {'trackView': trackView},
    );

    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Invalid profile response',
      );
    }

    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Profile data missing',
      );
    }

    return PublicUserProfileApiModel.fromJson(data);
  }
}
