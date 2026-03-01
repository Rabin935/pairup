import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pairup/core/error/failures.dart';
import 'package:pairup/core/usecases/app_usecase.dart';
import 'package:pairup/features/user/data/repositories/user_media_repository.dart';
import 'package:pairup/features/user/domain/entities/upload_user_images_result_entity.dart';
import 'package:pairup/features/user/domain/repositories/user_media_repository.dart';

class UploadUserImagesUsecaseParams extends Equatable {
  final List<String> imageFilePaths;

  const UploadUserImagesUsecaseParams({required this.imageFilePaths});

  @override
  List<Object?> get props => [imageFilePaths];
}

final uploadUserImagesUsecaseProvider = Provider<UploadUserImagesUsecase>((
  ref,
) {
  return UploadUserImagesUsecase(
    repository: ref.read(userMediaRepositoryProvider),
  );
});

class UploadUserImagesUsecase
    implements
        UsecaseWithParams<
          UploadUserImagesResultEntity,
          UploadUserImagesUsecaseParams
        > {
  final IUserMediaRepository _repository;

  UploadUserImagesUsecase({required IUserMediaRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, UploadUserImagesResultEntity>> call(
    UploadUserImagesUsecaseParams params,
  ) {
    return _repository.uploadUserImages(params.imageFilePaths);
  }
}
