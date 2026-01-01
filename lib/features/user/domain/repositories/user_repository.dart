import 'package:either_dart/either.dart';
import 'package:pairup/core/error/failures.dart';
import 'package:pairup/features/user/domain/entities/user_entities.dart';

abstract interface class IUserRepository {
  Future<Either<Failure, List<UserEntity>>> getAllUser();
  Future<Either<Failure, UserEntity>> getUserbyId(String userId);
  Future<Either<Failure, bool>> createBatch(UserEntity user);
  Future<Either<Failure, bool>> updateBatch(UserEntity user);
  Future<Either<Failure, bool>> deleteBatch(String user);
  Future<Either<Failure, bool>> saveUser(UserEntity user);
}
