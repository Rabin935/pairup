import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pairup/core/error/failures.dart';
import 'package:pairup/core/usecases/app_usecase.dart';
import 'package:pairup/features/user/data/repositories/user_media_repository.dart';
import 'package:pairup/features/user/domain/entities/user_image_like_result_entity.dart';
import 'package:pairup/features/user/domain/repositories/user_media_repository.dart';

class ToggleUserImageLikeUsecaseParams extends Equatable {
  final String userId;
  final String imageId;

  const ToggleUserImageLikeUsecaseParams({
    required this.userId,
    required this.imageId,
  });

  @override
  List<Object?> get props => [userId, imageId];
}

final toggleUserImageLikeUsecaseProvider = Provider<ToggleUserImageLikeUsecase>(
  (ref) {
    return ToggleUserImageLikeUsecase(
      repository: ref.read(userMediaRepositoryProvider),
    );
  },
);

class ToggleUserImageLikeUsecase
    implements
        UsecaseWithParams<
          UserImageLikeResultEntity,
          ToggleUserImageLikeUsecaseParams
        > {
  final IUserMediaRepository _repository;

  ToggleUserImageLikeUsecase({required IUserMediaRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, UserImageLikeResultEntity>> call(
    ToggleUserImageLikeUsecaseParams params,
  ) {
    return _repository.toggleUserImageLike(
      userId: params.userId,
      imageId: params.imageId,
    );
  }
}
