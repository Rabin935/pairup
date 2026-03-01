import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pairup/core/error/failures.dart';
import 'package:pairup/core/services/connectivity/network_info.dart';
import 'package:pairup/features/user/data/datasource/remote/user_media_remote_datasource.dart';
import 'package:pairup/features/user/domain/entities/upload_user_images_result_entity.dart';
import 'package:pairup/features/user/domain/entities/user_image_like_result_entity.dart';
import 'package:pairup/features/user/domain/repositories/user_media_repository.dart';

final userMediaRepositoryProvider = Provider<IUserMediaRepository>((ref) {
  return UserMediaRepository(
    remoteDatasource: ref.read(userMediaRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class UserMediaRepository implements IUserMediaRepository {
  final IUserMediaRemoteDatasource _remoteDatasource;
  final NetworkInfo _networkInfo;

  UserMediaRepository({
    required IUserMediaRemoteDatasource remoteDatasource,
    required NetworkInfo networkInfo,
  }) : _remoteDatasource = remoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, UploadUserImagesResultEntity>> uploadUserImages(
    List<String> imageFilePaths,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }

    try {
      final model = await _remoteDatasource.uploadUserImages(imageFilePaths);
      return Right(model.toEntity());
    } on DioException catch (error) {
      return Left(
        ApiFailure(
          message: _extractMessage(error, fallback: 'Unable to upload images'),
          statusCode: error.response?.statusCode,
        ),
      );
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, UserImageLikeResultEntity>> toggleUserImageLike({
    required String userId,
    required String imageId,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }

    try {
      final model = await _remoteDatasource.toggleUserImageLike(
        userId: userId,
        imageId: imageId,
      );
      return Right(model.toEntity());
    } on DioException catch (error) {
      return Left(
        ApiFailure(
          message: _extractMessage(
            error,
            fallback: 'Unable to update post like',
          ),
          statusCode: error.response?.statusCode,
        ),
      );
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }
}

String _extractMessage(DioException error, {required String fallback}) {
  final responseData = error.response?.data;
  if (responseData is Map<String, dynamic>) {
    final message = responseData['message']?.toString().trim() ?? '';
    if (message.isNotEmpty) return message;
  }
  final message = error.message?.trim() ?? '';
  if (message.isNotEmpty) return message;
  return fallback;
}
