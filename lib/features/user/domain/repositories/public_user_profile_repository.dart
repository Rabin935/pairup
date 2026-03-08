import 'package:dartz/dartz.dart';
import 'package:pairup/core/error/failures.dart';
import 'package:pairup/features/user/domain/entities/public_user_profile_entity.dart';

abstract interface class IPublicUserProfileRepository {
  Future<Either<Failure, PublicUserProfileEntity>> getPublicUserProfile(
    String userId, {
    bool trackView = true,
  });
}
