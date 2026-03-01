import 'package:dartz/dartz.dart';
import 'package:pairup/core/error/failures.dart';
import 'package:pairup/features/user/domain/entities/upload_user_images_result_entity.dart';
import 'package:pairup/features/user/domain/entities/user_image_like_result_entity.dart';

abstract interface class IUserMediaRepository {
  Future<Either<Failure, UploadUserImagesResultEntity>> uploadUserImages(
    List<String> imageFilePaths,
  );

  Future<Either<Failure, UserImageLikeResultEntity>> toggleUserImageLike({
    required String userId,
    required String imageId,
  });
}
