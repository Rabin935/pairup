import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pairup/core/error/failures.dart';
import 'package:pairup/features/user/data/datasource/remote/public_user_profile_remote_datasource.dart';
import 'package:pairup/features/user/domain/entities/public_user_profile_entity.dart';
import 'package:pairup/features/user/domain/repositories/public_user_profile_repository.dart';

final publicUserProfileRepositoryProvider =
    Provider<IPublicUserProfileRepository>((ref) {
      return PublicUserProfileRepository(
        remoteDatasource: ref.read(publicUserProfileRemoteDatasourceProvider),
      );
    });

class PublicUserProfileRepository implements IPublicUserProfileRepository {
  final IPublicUserProfileRemoteDatasource _remoteDatasource;

  PublicUserProfileRepository({
    required IPublicUserProfileRemoteDatasource remoteDatasource,
  }) : _remoteDatasource = remoteDatasource;

  @override
  Future<Either<Failure, PublicUserProfileEntity>> getPublicUserProfile(
    String userId, {
    bool trackView = true,
  }) async {
    try {
      final model = await _remoteDatasource.getPublicUserProfile(
        userId,
        trackView: trackView,
      );
      return Right(model.toEntity());
    } on DioException catch (error) {
      final responseData = error.response?.data;
      String message = 'Unable to load user profile';

      if (responseData is Map<String, dynamic>) {
        final rawMessage = responseData['message']?.toString().trim() ?? '';
        if (rawMessage.isNotEmpty) {
          message = rawMessage;
        }
      } else {
        final dioMessage = error.message?.trim() ?? '';
        if (dioMessage.isNotEmpty) {
          message = dioMessage;
        }
      }

      return Left(
        ApiFailure(message: message, statusCode: error.response?.statusCode),
      );
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }
}
