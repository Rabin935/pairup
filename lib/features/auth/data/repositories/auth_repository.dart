import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pairup/core/error/failures.dart';
import 'package:pairup/features/auth/data/datasource/auth_datasource.dart';
import 'package:pairup/features/auth/data/datasource/local/auth_local_datasource.dart';
import 'package:pairup/features/auth/data/datasource/remote/auth_remote_datasource.dart';
import 'package:pairup/features/auth/data/models/auth_api_model.dart';
import 'package:pairup/features/auth/data/models/auth_hive_model.dart';
import 'package:pairup/features/auth/domain/entities/auth_entity.dart';
import 'package:pairup/features/auth/domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final authLocalDatasource = ref.read(authLocalDatasourceProvider);
  final authRemoteDatasource = ref.read(authRemoteDatasourceProvider);

  return AuthRepository(
    authLocalDatasource: authLocalDatasource,
    authRemoteDatasource: authRemoteDatasource,
  );
});

class AuthRepository implements IAuthRepository {
  final IAuthLocalDataSource _authLocalDatasource;
  final IAuthRemoteDataSource _authRemoteDatasource;

  AuthRepository({
    required IAuthLocalDataSource authLocalDatasource,
    required IAuthRemoteDataSource authRemoteDatasource,
  }) : _authLocalDatasource = authLocalDatasource,
       _authRemoteDatasource = authRemoteDatasource;

  @override
  Future<Either<Failure, bool>> register(AuthEntity user) async {
    try {
      final apiModel = AuthApiModel.fromEntity(user);
      await _authRemoteDatasource.register(apiModel);
      return const Right(true);
    } on DioException catch (e) {
      if (_isConnectionError(e)) {
        return _registerOffline(user);
      }

      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message: _extractDioMessage(e, fallback: "Registration failed"),
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(
    String email,
    String password,
  ) async {
    try {
      final apiModel = await _authRemoteDatasource.login(email, password);
      if (apiModel != null) {
        final entity = apiModel.toEntity();
        return Right(entity);
      }

      return const Left(ApiFailure(message: "Invalid credentials"));
    } on DioException catch (e) {
      if (_isConnectionError(e)) {
        try {
          final model = await _authLocalDatasource.login(email, password);
          if (model != null) {
            return Right(model.toEntity());
          }
          return const Left(
            ApiFailure(
              message:
                  "Unable to reach server. Check backend connection and try again.",
            ),
          );
        } catch (_) {
          return const Left(
            ApiFailure(
              message:
                  "Unable to reach server. Check backend connection and try again.",
            ),
          );
        }
      }

      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message: _extractDioMessage(e, fallback: "Login failed"),
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final model = await _authLocalDatasource.getCurrentUser();
      if (model != null) {
        final entity = model.toEntity();
        return Right(entity);
      }
      return const Left(LocalDatabaseFailure(message: "No user logged in"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final result = await _authLocalDatasource.logout();
      if (result) {
        return const Right(true);
      }
      return const Left(LocalDatabaseFailure(message: "Failed to logout"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, bool>> _registerOffline(AuthEntity user) async {
    try {
      final existingUser = await _authLocalDatasource.getUserByEmail(
        user.email,
      );
      if (existingUser != null) {
        return const Left(
          LocalDatabaseFailure(message: "Email already registered"),
        );
      }

      final authModel = AuthHiveModel.fromEntity(user);
      final result = await _authLocalDatasource.register(authModel);

      if (result) {
        return const Right(true);
      }
      return const Left(
        LocalDatabaseFailure(message: "Failed to register user"),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  bool _isConnectionError(DioException e) {
    return e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout;
  }

  String _extractDioMessage(DioException e, {required String fallback}) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message']?.toString().trim() ?? '';
      if (message.isNotEmpty) return message;
    }
    final message = e.message?.trim() ?? '';
    if (message.isNotEmpty) return message;
    return fallback;
  }
}
