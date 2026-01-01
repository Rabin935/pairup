import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pairup/core/error/failures.dart';
import 'package:pairup/features/user/data/datasource/local/user_local_datasource.dart';
import 'package:pairup/features/user/data/datasource/user_datasource.dart';
import 'package:pairup/features/user/data/models/user_hive_model.dart';
import 'package:pairup/features/user/domain/entities/user_entities.dart';
import 'package:pairup/features/user/domain/repositories/user_repository.dart';

final userRepositoryProvider = Provider<IUserRepository>((ref) {
  return UserRepository(datasource: ref.read(userLocalDataSourceProvider));
});

class UserRepository implements IUserRepository {
  final IUserDatasource _datasource;

  UserRepository({required IUserDatasource datasource})
    : _datasource = datasource;

  @override
  Future<Either<Failure, bool>> createUser(UserEntity user) async {
    try {
      final model = UserHiveModel.fromEntity(user);
      final result = await _datasource.createUser(model);
      if (result) {
        return const Right(true);
      }
      return const Left(LocalDatabaseFailure(message: "Failed to create user"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteUser(String userId) async {
    try {
      final result = await _datasource.deleteUser(userId);
      if (result) {
        return const Right(true);
      }
      return const Left(LocalDatabaseFailure(message: "Failed to create user"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserEntity>>> getAllUser() async {
    try {
      final models = await _datasource.getAllUser();
      final entities = UserHiveModel.toEntityList(models);
      return Right(entities);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getUserbyId(String userId) async {
    try {
      final model = await _datasource.getUserbyId(userId);
      if (model != null) {
        final entity = model.toEntity();
        return Right(entity);
      }
      return Left(LocalDatabaseFailure(message: 'User not found'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> saveUser(UserEntity user) async {
    try {
      final usermodel = UserHiveModel.fromEntity(user);
      final result = await _datasource.saveUser(usermodel);
      if (result) {
        return const Right(true);
      }
      return const Left(LocalDatabaseFailure(message: "Failed to create user"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateUser(UserEntity user) async {
    try {
      final userModel = UserHiveModel.fromEntity(user);
      final result = await _datasource.updateUser(userModel);
      if (result) {
        return const Right(true);
      }
      return const Left(
        LocalDatabaseFailure(message: "Failed to update user's detail"),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}
