import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pairup/core/error/failures.dart';
import 'package:pairup/core/services/connectivity/network_info.dart';
import 'package:pairup/features/chat/data/datasource/chat_datasource.dart';
import 'package:pairup/features/chat/data/datasource/remote/chat_remote_datasource.dart';
import 'package:pairup/features/chat/domain/entities/chat_entities.dart';
import 'package:pairup/features/chat/domain/repositories/chat_repository.dart';

final chatRepositoryProvider = Provider<IChatRepository>((ref) {
  return ChatRepository(
    remoteDataSource: ref.read(chatRemoteDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class ChatRepository implements IChatRepository {
  final IChatRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  ChatRepository({
    required IChatRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  }) : _remoteDataSource = remoteDataSource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, ChatOverviewEntity>> getChatOverview({
    required String currentUserId,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }

    try {
      final model = await _remoteDataSource.getChatOverview(
        currentUserId: currentUserId,
      );
      return Right(model.toEntity());
    } on DioException catch (e) {
      final message = (e.response?.data is Map<String, dynamic>)
          ? ((e.response?.data['message'] as String?) ?? 'Failed to load chats')
          : (e.message ?? 'Failed to load chats');
      return Left(
        ApiFailure(message: message, statusCode: e.response?.statusCode),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
