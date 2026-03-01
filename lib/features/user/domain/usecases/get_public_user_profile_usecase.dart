import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pairup/core/error/failures.dart';
import 'package:pairup/core/usecases/app_usecase.dart';
import 'package:pairup/features/user/data/repositories/public_user_profile_repository.dart';
import 'package:pairup/features/user/domain/entities/public_user_profile_entity.dart';
import 'package:pairup/features/user/domain/repositories/public_user_profile_repository.dart';

class GetPublicUserProfileUsecaseParams extends Equatable {
  final String userId;
  final bool trackView;

  const GetPublicUserProfileUsecaseParams({
    required this.userId,
    this.trackView = true,
  });

  @override
  List<Object?> get props => [userId, trackView];
}

final getPublicUserProfileUsecaseProvider =
    Provider<GetPublicUserProfileUsecase>((ref) {
      final repository = ref.read(publicUserProfileRepositoryProvider);
      return GetPublicUserProfileUsecase(repository: repository);
    });

class GetPublicUserProfileUsecase
    implements
        UsecaseWithParams<
          PublicUserProfileEntity,
          GetPublicUserProfileUsecaseParams
        > {
  final IPublicUserProfileRepository _repository;

  GetPublicUserProfileUsecase({
    required IPublicUserProfileRepository repository,
  }) : _repository = repository;

  @override
  Future<Either<Failure, PublicUserProfileEntity>> call(
    GetPublicUserProfileUsecaseParams params,
  ) {
    return _repository.getPublicUserProfile(
      params.userId,
      trackView: params.trackView,
    );
  }
}
