import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pairup/core/api/api_client.dart';
import 'package:pairup/features/user/data/models/upload_user_images_result_api_model.dart';
import 'package:pairup/features/user/data/models/user_image_like_result_api_model.dart';

abstract interface class IUserMediaRemoteDatasource {
  Future<UploadUserImagesResultApiModel> uploadUserImages(
    List<String> imageFilePaths,
  );

  Future<UserImageLikeResultApiModel> toggleUserImageLike({
    required String userId,
    required String imageId,
  });
}

final userMediaRemoteDatasourceProvider = Provider<IUserMediaRemoteDatasource>((
  ref,
) {
  return UserMediaRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class UserMediaRemoteDatasource implements IUserMediaRemoteDatasource {
  final ApiClient _apiClient;

  UserMediaRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<UploadUserImagesResultApiModel> uploadUserImages(
    List<String> imageFilePaths,
  ) async {
    final cleanPaths = imageFilePaths.map((path) => path.trim()).toList();
    if (cleanPaths.isEmpty) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/users/upload-images'),
        error: 'No image selected',
      );
    }

    final files = await Future.wait(
      cleanPaths.map(
        (path) => MultipartFile.fromFile(
          path,
          filename: path.split(RegExp(r'[\\/]')).last,
        ),
      ),
    );

    final formData = FormData.fromMap({'images': files});
    final response = await _apiClient.post(
      '/api/users/upload-images',
      data: formData,
    );

    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Invalid upload response',
      );
    }

    return UploadUserImagesResultApiModel.fromResponse(body);
  }

  @override
  Future<UserImageLikeResultApiModel> toggleUserImageLike({
    required String userId,
    required String imageId,
  }) async {
    final normalizedUserId = userId.trim();
    final normalizedImageId = imageId.trim();

    if (normalizedUserId.isEmpty || normalizedImageId.isEmpty) {
      throw DioException(
        requestOptions: RequestOptions(
          path: '/api/users/$normalizedUserId/images/$normalizedImageId/like',
        ),
        error: 'userId and imageId are required',
      );
    }

    final response = await _apiClient.post(
      '/api/users/${Uri.encodeComponent(normalizedUserId)}/images/${Uri.encodeComponent(normalizedImageId)}/like',
    );

    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Invalid like response',
      );
    }

    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Like response data missing',
      );
    }

    return UserImageLikeResultApiModel.fromJson(data);
  }
}
